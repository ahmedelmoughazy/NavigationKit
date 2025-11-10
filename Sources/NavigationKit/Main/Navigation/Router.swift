//
//  Router.swift
//  NavigationKit
//
//  Created by Ahmed Elmoughazy on 29.02.24
//  Copyright © 2024 Ahmed Elmoghazy. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - Router

/// A hierarchical navigation state manager that provides programmatic navigation capabilities.
///
/// `Router` manages navigation state and supports both stack-based navigation (push/pop) 
/// and modal presentations (sheets and full-screen covers). It maintains a hierarchy of 
/// child routers for modal presentations and provides reactive updates through Combine publishers.
///
/// ## Features
/// - **Stack Navigation**: Push and pop destinations in a navigation stack
/// - **Modal Presentations**: Present destinations as sheets or full-screen covers
/// - **Hierarchical Management**: Automatic child router creation for modal presentations
/// - **Reactive Updates**: Published properties and Combine publishers for state changes
/// - **Animation Control**: Optional animation control for all navigation actions
///
/// ## Basic Usage
/// ```swift
/// let router = Router()
///
/// // Stack navigation
/// router.push(destination: .home)
/// router.pop()
///
/// // Modal presentation
/// router.present(destination: .settings, as: .sheet)
/// router.dismiss()
/// ```
///
/// ## Hierarchy
/// Routers form a hierarchy where:
/// - Root router manages the main navigation stack
/// - Child routers are created automatically for modal presentations
/// - Navigation state changes propagate through the hierarchy
///
/// - Note: Destination views must conform to Hashable, Identifiable, and View protocols
/// - SeeAlso: `BaseNavigation` for the SwiftUI integration
/// - SeeAlso: `Presentation` for modal presentation options
public final class Router: ObservableObject {
    
    // MARK: - Initialization
    
    /// Creates a new router instance.
    public init() {}
    
    // MARK: - Properties
    
    /// The current navigation path as an array of destinations.
    @Published internal var navigationPath: [AnyDestination] = [] {
        didSet { notifyHierarchyChanged() }
    }
    
    /// The currently presented sheet destination, if any.
    @Published internal var presentingSheet: AnyDestination? = nil {
        didSet { notifyHierarchyChanged() }
    }
    
    /// The currently presented full-screen cover destination, if any.
    @Published internal var presentingFullScreen: AnyDestination? = nil {
        didSet { notifyHierarchyChanged() }
    }
    
    /// The currently presented alert, if any.
    @Published internal var alertItem: AlertItem? = nil
    
    /// The parent router in the hierarchy, if this is a child router.
    internal weak var parentRouter: Router? {
        didSet { notifyHierarchyChanged() }
    }
    
    /// The child router created for modal presentations, if any.
    internal weak var childRouter: Router? {
        didSet { notifyHierarchyChanged() }
    }
    
    /// Returns the root router in the hierarchy.
    ///
    /// Traverses up the parent chain to find the topmost router.
    internal var rootRouter: Router {
        var node: Router = self
        while let parent = node.parentRouter {
            node = parent
        }
        return node
    }
    
    // MARK: - Private Properties

    /// Returns the root notification subject for hierarchy-wide change notifications.
    private var rootNotifier: PassthroughSubject<Void, Never> {
        parentRouter?.rootNotifier ?? rootSubject
    }
    
    /// The root-level change notification subject.
    private var rootSubject = PassthroughSubject<Void, Never>()
}

// MARK: - Route Tracking
public extension Router {
    
    /// Returns the currently active router in the hierarchy.
    ///
    /// This is either the child router (if one exists) or this router itself.
    /// The active router is the one that should handle new navigation actions.
    var activeRouter: Router {
        childRouter ?? self
    }
    
    /// Returns the current route as an array of destination descriptions.
    ///
    /// Traverses the entire router hierarchy and collects all destinations
    /// in the navigation paths, sheets, and full-screen presentations.
    ///
    /// - Returns: An array of strings representing the current route
    var currentRoute: [String] {
        var ids: [String] = []
        var node: Router? = rootRouter
        while let router = node {
            ids.append(contentsOf: router.navigationPath.map { $0.id })
            if let sheet = router.presentingSheet {
                ids.append(sheet.id)
            }
            if let fullScreen = router.presentingFullScreen {
                ids.append(fullScreen.id)
            }
            node = router.childRouter
        }
        return ids
    }
    
    /// A publisher that emits the current route whenever the navigation state changes.
    ///
    /// This publisher provides reactive updates to the current route, allowing
    /// views and other components to respond to navigation changes.
    ///
    /// - Returns: A publisher that emits route arrays on navigation changes
    var currentRoutePublisher: AnyPublisher<[String], Never> {
        let currentRoute = self.currentRoute
        return rootNotifier
            .map { [weak self] in
                guard let self else { return [] }
                return self.currentRoute
            }
            .prepend(currentRoute)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

// MARK: - Stack Navigation
public extension Router {
    
    /// Pushes a destination onto the navigation stack.
    ///
    /// - Parameters:
    ///   - destination: The destination to push
    ///   - animated: Whether to animate the transition (default: true)
    func push<Destination: View>(destination: Destination, animated: Bool = true) {
        execute(animated) { [weak self] in
            self?.navigationPath.append(AnyDestination(destination))
        }
    }
    
    /// Pops the most recent destination from the navigation stack.
    ///
    /// - Parameter animated: Whether to animate the transition (default: true)
    func pop(animated: Bool = true) {
        execute(animated) { [weak self] in
            self?.navigationPath.removeLast()
        }
    }
    
    /// Pops the navigation stack to a specific destination.
    ///
    /// Removes all destinations after the specified destination from the stack.
    ///
    /// - Parameters:
    ///   - destination: The destination to pop back to
    ///   - animated: Whether to animate the transition (default: true)
    func pop<Destination: View>(to destination: Destination, animated: Bool = true) {
        if let indexOfDestination = navigationPath.lastIndex(where: { $0.id == AnyDestination(destination).id }) {
            let removeStart = indexOfDestination + 1
            if removeStart < navigationPath.count {
                execute(animated) { [weak self] in
                    guard let self else { return }
                    self.navigationPath.removeSubrange(removeStart..<self.navigationPath.count)
                }
            }
        }
    }
    
    /// Pops all destinations from the current navigation stack.
    ///
    /// - Parameter animated: Whether to animate the transition (default: true)
    func popToPresentation(animated: Bool = true) {
        execute(animated) { [weak self] in
            self?.navigationPath.removeAll()
        }
    }
    
    /// Pops all destinations and dismisses all modal presentations.
    ///
    /// This method clears the entire navigation hierarchy, returning to the root state.
    ///
    /// - Parameter animated: Whether to animate the transition (default: true)
    func popAll(animated: Bool = true) {
        execute(animated) { [weak self] in
            self?.dismissAlert(animated: animated)
            self?.dismiss(animated: animated)
            self?.parentRouter?.popAll(animated: animated)
            self?.navigationPath.removeAll()
        }
    }
}

// MARK: - Modal Presentation
public extension Router {
    
    /// Presents a destination modally.
    ///
    /// - Parameters:
    ///   - destination: The destination to present
    ///   - presentationType: The type of modal presentation
    ///   - animated: Whether to animate the transition (default: true)
    func present<Destination: View>(destination: Destination, as presentationType: Presentation, animated: Bool = true) {
        execute(animated) { [weak self] in
            switch presentationType {
            case .sheet:
                self?.presentingSheet = AnyDestination(destination)
            case .fullScreenCover:
                self?.presentingFullScreen = AnyDestination(destination)
            }
        }
    }
    
    /// Dismisses the current modal presentation.
    ///
    /// - Parameter animated: Whether to animate the transition (default: true)
    func dismiss(animated: Bool = true) {
        execute(animated) { [weak self] in
            if self?.parentRouter?.presentingSheet != nil {
                self?.parentRouter?.presentingSheet = nil
                self?.parentRouter?.childRouter = nil
            } else if self?.parentRouter?.presentingFullScreen != nil {
                self?.parentRouter?.presentingFullScreen = nil
                self?.parentRouter?.childRouter = nil
            }
        }
    }
}

// MARK: - Alert Presentation
public extension Router {
    
    /// Presents an alert without interfering with modal presentations.
    ///
    /// - Parameters:
    ///   - alertItem: The alert configuration to present
    ///   - animated: Whether to animate the transition (default: true)
    func presentAlert(alertItem: AlertItem, animated: Bool = true) {
        execute(animated) { [weak self] in
            self?.alertItem = alertItem
        }
    }
    
    /// Dismisses the currently presented alert.
    ///
    /// - Parameter animated: Whether to animate the transition (default: true)
    func dismissAlert(animated: Bool = true) {
        execute(animated) { [weak self] in
            self?.alertItem = nil
        }
    }
}

// MARK: - Advanced Navigation
public extension Router {
    
    /// Inserts a destination at a specific index in the navigation stack.
    ///
    /// - Parameters:
    ///   - destination: The destination to insert
    ///   - index: The index at which to insert the destination
    ///   - animated: Whether to animate the transition (default: true)
    func insert<Destination: View>(destination: Destination, at index: Int, animated: Bool = true) {
        var tempPath = navigationPath
        tempPath.insert(AnyDestination(destination), at: index)
        
        execute(animated) { [weak self] in
            self?.navigationPath = tempPath
        }
    }
    
    /// Removes specific destinations from the navigation stack.
    ///
    /// - Parameters:
    ///   - destinations: The destinations to remove
    ///   - animated: Whether to animate the transition (default: true)
    func remove<Destination: View>(destinations: Destination..., animated: Bool = true) {
        var tempPath = navigationPath
        destinations.forEach { destination in
            if let index = tempPath.lastIndex(where: { $0.id == AnyDestination(destination).id }) {
                tempPath.remove(at: index)
            }
        }
        
        execute(animated) { [weak self] in
            self?.navigationPath = tempPath
        }
    }
    
    /// Replaces the current navigation path with a new path.
    ///
    /// - Parameters:
    ///   - destinations: The new navigation path
    ///   - animated: Whether to animate the transition (default: true)
    func applyPath<Destination: View>(_ destinations: [Destination], animated: Bool = true) {
        let newPath = destinations.map { AnyDestination($0) }
        
        execute(animated) { [weak self] in
            self?.navigationPath = newPath
        }
    }
}

// MARK: - Router Management
internal extension Router {
    
    /// Creates a child router for modal presentations.
    ///
    /// Child routers are automatically created when presenting modals and
    /// maintain a parent-child relationship for hierarchy management.
    ///
    /// - Returns: A new child router instance
    func createChildRouter() -> Router {
        let childRouter = Router()
        self.childRouter = childRouter
        childRouter.parentRouter = self
        return childRouter
    }
    
    /// Removes the current child router from the hierarchy.
    ///
    /// This method is called when sheet modal presentation is dismissed to
    /// clean up the router hierarchy and break the parent-child relationship.
    /// It's typically invoked automatically by BaseNavigation when sheet presentations
    /// is dismissed, but it was mainly called for dismissal by the user.
    ///
    /// ## Usage Context
    /// This method is primarily used internally by the navigation system:
    /// - Called when sheets are dismissed via the `.sheet()` modifier's `onDismiss` closure
    /// - Ensures proper cleanup of navigation hierarchy, when dismissed by user.
    ///
    /// - Note: This method only removes the direct child router, not nested children
    /// - SeeAlso: `createChildRouter()` for child router creation
    /// - SeeAlso: `BaseNavigation` for automatic cleanup integration
    func removeChildRouter() {
        self.childRouter = nil
    }
}

// MARK: - Private Methods
private extension Router {
    
    /// Executes a navigation action with optional animation control.
    ///
    /// - Parameters:
    ///   - animated: Whether to animate the navigation action
    ///   - navigation: The navigation action to execute
    func execute(_ animated: Bool, _ navigation: @escaping () -> Void) {
        if animated {
            navigation()
        } else {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                navigation()
            }
        }
    }
    
    /// Notifies the hierarchy that navigation state has changed.
    ///
    /// This method triggers updates to all subscribers listening for
    /// navigation changes throughout the router hierarchy.
    func notifyHierarchyChanged() {
        rootNotifier.send(())
    }
}
