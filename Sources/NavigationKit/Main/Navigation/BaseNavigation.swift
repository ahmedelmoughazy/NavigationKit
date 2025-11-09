//
//  BaseNavigation.swift
//  NavigationKit
//
//  Created by Ahmed Elmoughazy on 08.08.25
//  Copyright © 2025 Ahmed Elmoghazy. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - BaseNavigation

/// A foundational navigation container that provides hierarchical navigation capabilities.
///
/// `BaseNavigation` serves as the core navigation wrapper that manages navigation stacks,
/// modal presentations (sheets and full-screen covers), and router hierarchy. It automatically
/// handles child router creation and maintains the navigation state throughout the app.
///
/// ## Features
/// - **Hierarchical Navigation**: Supports nested navigation with automatic child router management
/// - **Modal Presentations**: Built-in support for sheets and full-screen covers
/// - **Debug Integration**: Automatic hierarchy logging for development builds
/// - **Type Safety**: Strong typing for destinations with protocol requirements
///
/// ## Usage
/// ```swift
/// BaseNavigation(router: mainRouter) {
///     HomeView()
/// }
/// ```
///
/// ## Type Requirements
/// The `Destination` type must conform to:
/// - `Routable`: For path management.
///
/// - Note: This view automatically creates child routers for modal presentations
/// - SeeAlso: `Router` for navigation state management
public struct BaseNavigation<Content: View, Destination: Routable>: View {
    
    // MARK: - Properties
    
    /// The router managing navigation state for this navigation container.
    @StateObject private var router: Router<Destination>
    
    /// The root content view builder for this navigation container.
    @ViewBuilder private let content: () -> Content
    
    // MARK: - Initialization
    
    /// Creates a new navigation container with the specified router and content.
    ///
    /// - Parameters:
    ///   - router: The router instance to manage navigation state
    ///   - content: A view builder that provides the root content for this navigation container
    public init(
        router: Router<Destination>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._router = StateObject(wrappedValue: router)
        self.content = content
    }
    
    // MARK: - View Body
    
    public var body: some View {
        NavigationStack(path: $router.navigationPath) {
            content()
                .navigationDestination(for: Destination.self) { $0 }
        }
        .environmentObject(router.activeRouter)
        .sheet(item: $router.presentingSheet) {
            router.removeChildRouter()
        } content: { destination in
            createSheetContent(for: destination)
        }
        #if os(iOS)
        .fullScreenCover(item: $router.presentingFullScreen) {
            router.removeChildRouter()
        } content: { destination in
            createFullScreenContent(for: destination)
        }
        #endif
        .alert(alertItem: $router.alertItem)
        .onChange(of: router.navigationPath) { _ in
            logNavigationHierarchy()
        }
        .onChange(of: router.presentingSheet) { _ in
            logNavigationHierarchy()
        }
        .onChange(of: router.presentingFullScreen) { _ in
            logNavigationHierarchy()
        }
    }
}

// MARK: - Private Methods
private extension BaseNavigation {
    
    /// Creates the content for sheet presentations.
    /// - Parameter destination: The destination view to present in the sheet
    /// - Returns: A new BaseNavigation instance with a child router
    func createSheetContent(for destination: Destination) -> some View {
        let childRouter = router.createChildRouter()
        return BaseNavigation<AnyView, Destination>(router: childRouter) {
            AnyView(destination)
        }
    }
    
    /// Creates the content for full-screen cover presentations.
    /// - Parameter destination: The destination view to present full-screen
    /// - Returns: A new BaseNavigation instance with a child router
    func createFullScreenContent(for destination: Destination) -> some View {
        let childRouter = router.createChildRouter()
        return BaseNavigation<AnyView, Destination>(router: childRouter) {
            AnyView(destination)
        }
    }
    
    /// Logs the current navigation hierarchy for debugging purposes.
    /// Only active in DEBUG builds through the router's debug functionality.
    func logNavigationHierarchy() {
        #if DEBUG
        router.debugPrintCompleteHierarchy()
        #endif
    }
}
