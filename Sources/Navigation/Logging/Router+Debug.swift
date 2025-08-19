//
//  Router+Debug.swift
//  Navigation
//
//  Created by Ahmed Elmoughazy on 19.08.25.
//
#if DEBUG
import Foundation
import Combine

extension Router {

    var rootRouter: Router {
        var node: Router = self
        while let parent = node.parentRouter { node = parent }
        return node
    }
    
    var rootNotifier: PassthroughSubject<Void, Never> { parentRouter?.rootNotifier ?? PassthroughSubject<Void, Never>() }
    
    func notifyHierarchyChanged() {
        rootNotifier.send(())
    }
    
    /// Print the hierarchy starting from the root router
    func debugPrintHierarchyFromRoot() {
        rootRouter.debugPrintHierarchy()
    }
    
    func debugPrintHierarchy(level: Int = 0, prefix: String = "", isLast: Bool = true) {
        // Build a compact, clean ID suffix (keep only hex digits and take last 5)
        let rawId = ObjectIdentifier(self).debugDescription
        let hexSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
        let hexScalars = rawId.unicodeScalars.filter { hexSet.contains($0) }
        let hexString = String(String.UnicodeScalarView(hexScalars))
        let idSuffix = String(hexString.suffix(5))

        // Draw connector only on the node line
        let nodeConnector = level == 0 ? "" : (isLast ? "└── " : "├── ")
        print("\(prefix)\(nodeConnector)🎯 Router#\(idSuffix)")

        // Content lines align under the node label without extra connectors
        // Root gets two spaces; children get continuation spacing
        let contentIndent = level == 0 ? (prefix + "  ") : (prefix + (isLast ? "    " : "│   "))

        if !navigationPath.isEmpty {
            let pathIds = navigationPath.map { $0.description }
            print("\(contentIndent)📱 Path: \(pathIds)")
        }
        if let sheet = presentingSheet {
            print("\(contentIndent)📄 Sheet: \(sheet.description)")
        }
        if let full = presentingFullScreen {
            print("\(contentIndent)🖥️ FullScreen: \(full.description)")
        }

        if let child = childRouter {
            // Only one active child exists, so it's always the last
            let childPrefix = contentIndent
            child.debugPrintHierarchy(level: level + 1, prefix: childPrefix, isLast: true)
        }
    }

    /// Collect all route IDs from the root to the active leaf (including presentations)
    func allRouteIdsInHierarchy() -> [String] {
        var ids: [String] = []
        var node: Router? = rootRouter
        while let r = node {
            ids.append(contentsOf: r.navigationPath.map { $0.description })
            if let sheet = r.presentingSheet { ids.append(sheet.description) }
            if let full = r.presentingFullScreen { ids.append(full.description) }
            node = r.childRouter
        }
        return ids
    }
    
    /// Synchronous check
    func isInHierarchy(_ destination: Destination) -> Bool {
        let ids = Set(allRouteIdsInHierarchy())
        return ids.contains(destination.description)
    }
    
    /// Publisher that emits whether the given views are present anywhere in the active hierarchy
    func isViewInHierarchy(_ destination: Destination) -> AnyPublisher<Bool, Never> {
        let initial = isInHierarchy(destination)
        return rootNotifier
            .map { [weak self] in
                guard let self else { return false }
                return self.isInHierarchy(destination)
            }
            .prepend(initial)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
#endif
