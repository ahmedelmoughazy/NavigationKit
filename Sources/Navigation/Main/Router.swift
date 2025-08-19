//
//  Router.swift
//  NavigationPOC
//
//  Created by Ahmed Elmoughazy on 29.02.24.
//

import SwiftUI

public final class Router<Destination: Hashable & Identifiable & CustomStringConvertible & View>: ObservableObject {
    
    public init() {}
    
    public enum PresentationType {
        case sheet
        case fullScreenCover
    }
        
    weak var parentRouter: Router?
    weak var childRouter: Router? {
        didSet {
            notifyHierarchyChanged()
        }
    }
    
    @Published var navigationPath: [Destination] = [] {
        didSet { notifyHierarchyChanged() }
    }
    
    @Published var presentingSheet: Destination? = nil {
        didSet { notifyHierarchyChanged() }
    }
    
    @Published var presentingFullScreen: Destination? = nil {
        didSet { notifyHierarchyChanged() }
    }
        
    /// Returns the currently active router in the navigation hierarchy
    /// This is the primary way to access the router that's currently being used
    public var activeRouter: Router {
        childRouter ?? self
    }
            
    // MARK: - Navigation Methods
    public func push(destination: Destination, animated: Bool = true) {
        execute(animated) { [weak self] in
            self?.navigationPath.append(destination)
        }
    }
    
    public func pop(animated: Bool = true) {
        execute(animated) { [weak self] in
            self?.navigationPath.removeLast()
        }
    }
    
    public func pop(to destination: Destination, animated: Bool = true) {
        if let indexOfDestination = navigationPath.lastIndex(where: { $0 == destination }) {
            let removeStart = indexOfDestination + 1
            if removeStart < navigationPath.count {
                execute(animated) { [weak self] in
                    guard let self else { return }
                    self.navigationPath.removeSubrange(removeStart..<self.navigationPath.count)
                }
            }
        }
    }
    
    public func popToPresentation(animated: Bool = true) {
        execute(animated) { [weak self] in
            self?.navigationPath.removeAll()
        }
    }
    
    public func popAll(animated: Bool = true) {
        execute(animated) { [weak self] in
            self?.navigationPath.removeAll()
            self?.parentRouter?.popAll(animated: animated)
            self?.dismiss(animated: animated)
        }
    }
    
    public func present(destination: Destination, presentationType: PresentationType, animated: Bool = true) {
        execute(animated) { [weak self] in
            switch presentationType {
            case .sheet:
                self?.presentingSheet = destination
            case .fullScreenCover:
                self?.presentingFullScreen = destination
            }
        }
    }
    
    public func dismiss(animated: Bool = true) {
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
    
    public func insert(destination: Destination, at index: Int, animated: Bool = true) {
        var tempPath = navigationPath
        tempPath.insert(destination, at: index)
        
        execute(animated) { [weak self] in
            self?.navigationPath = tempPath
        }
    }
    
    public func remove(destinations: Destination..., animated: Bool = true) {
        var tempPath = navigationPath
        destinations.forEach { destination in
            if let index = tempPath.lastIndex(where: { $0.description == destination.description }) {
                tempPath.remove(at: index)
            }
        }
        
        execute(animated) { [weak self] in
            self?.navigationPath = tempPath
        }
    }
    
    public func applyPath(_ destinations: [Destination], animated: Bool = true) {
        let newPath = destinations.map { $0 }
        
        execute(animated) { [weak self] in
            self?.navigationPath = newPath
        }
    }
    
    // MARK: - Helpers
    private func execute(_ animated: Bool, _ navigation: @escaping () -> Void) {
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
}
