//
//  Router.swift
//  NavigationPOC
//
//  Created by Ahmed Elmoughazy on 29.02.24.
//

import SwiftUI

@Observable
public final class Router {
    
    public init() {}
    
    public enum PresentationType {
        case sheet
        case fullScreenCover
    }
        
    weak var parentRouter: Router?
    var navigationPath: [AnyRoutable] = []
    var presentingSheet: AnyRoutable? = nil
    var presentingFullScreen: AnyRoutable? = nil
    var currentPath: [AnyRoutable] { navigationPath + [presentingSheet, presentingFullScreen].compactMap { $0 } }
    
    // MARK: - Animation Helpers
    
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
    
    // MARK: - Navigation Methods
    
    public func push<Destination: Routable>(destination: Destination, animated: Bool = true) {
        execute(animated) { [weak self] in
            self?.navigationPath.append(AnyRoutable(destination))
        }
    }
    
    public func pop(animated: Bool = true) {
        execute(animated) { [weak self] in
            self?.navigationPath.removeLast()
        }
    }
    
    public func pop<Destination: Routable>(to destination: Destination, animated: Bool = true) {
        if let indexOfDestination = navigationPath.lastIndex(where: { $0 == AnyRoutable(destination) }) {
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
    
    public func present<Destination: Routable>(destination: Destination, presentationType: PresentationType, animated: Bool = true) {
        execute(animated) { [weak self] in
            switch presentationType {
            case .sheet:
                self?.presentingSheet = AnyRoutable(destination)
            case .fullScreenCover:
                self?.presentingFullScreen = AnyRoutable(destination)
            }
        }
    }
    
    public func dismiss(animated: Bool = true) {
        execute(animated) { [weak self] in
            if self?.parentRouter?.presentingSheet != nil {
                self?.parentRouter?.presentingSheet = nil
            } else if self?.parentRouter?.presentingFullScreen != nil {
                self?.parentRouter?.presentingFullScreen = nil
            }
        }
    }
    
    public func insert<Destination: Routable>(destination: Destination, at index: Int, animated: Bool = true) {
        var tempPath = navigationPath
        tempPath.insert(AnyRoutable(destination), at: index)
        
        execute(animated) { [weak self] in
            self?.navigationPath = tempPath
        }
    }
    
    public func remove<Destination: Routable>(destinations: Destination.Type..., animated: Bool = true) {
        var tempPath = navigationPath
        destinations.forEach { routable in
            if let index = tempPath.lastIndex(where: { $0.id == routable.routeId }) {
                tempPath.remove(at: index)
            }
        }
        
        execute(animated) { [weak self] in
            self?.navigationPath = tempPath
        }
    }
    
    public func applyPath<Destination: Routable>(_ destinations: [Destination], animated: Bool = true) {
        let newPath = destinations.map { AnyRoutable($0) }
        
        execute(animated) { [weak self] in
            self?.navigationPath = newPath
        }
    }
}
