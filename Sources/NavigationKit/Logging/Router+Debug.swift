//
//  Router+Debug.swift
//  NavigationKit
//
//  Created by Ahmed Elmoughazy on 19.08.25
//  Copyright © 2025 Ahmed Elmoghazy. All rights reserved.
//

import Foundation
import Combine

// MARK: - Logging Style

/// Defines the output format for router hierarchy logging.
public enum RouterLoggingStyle {
    /// Logging is disabled
    case disabled
    /// Hierarchical tree view with indentation and connectors
    case hierarchical
    /// Flat array view with all routers listed sequentially
    case flat
}

// MARK: - Debug Constants
private enum DebugConstants {
    static let routerIcon = "🎯"
    static let pathIcon = "📱"
    static let sheetIcon = "📄"
    static let fullScreenIcon = "🖥️"
    
    static let lastBranchConnector = "└── "
    static let middleBranchConnector = "├── "
    static let verticalConnector = "│   "
    static let emptyConnector = "    "
    static let rootIndent = "  "
    
    static let idSuffixLength = 5
}

// MARK: - Router Debug Extension
extension Router {
    
    // MARK: - Public Debug Methods
    
    /// Prints the complete router hierarchy starting from the root router.
    ///
    /// This method traverses up to the root router and then prints the entire
    /// hierarchy showing all active routers, their navigation paths,
    /// and presented content (sheets/fullscreen).
    ///
    /// The output format depends on the `loggingStyle` property:
    /// - `.disabled`: No output
    /// - `.hierarchical`: Tree view with indentation
    /// - `.flat`: Array view with sequential listing
    ///
    /// Example hierarchical output:
    /// ```
    /// 🎯 Router#a1b2c
    ///   📱 Path: [home, profile]
    ///   📄 Sheet: settings
    ///   └── 🎯 Router#d3e4f
    ///       📱 Path: [details]
    /// ```
    ///
    /// Example flat output:
    /// ```
    /// Routers: [
    ///   🎯 Router#a1b2c | 📱 Path: [home, profile] | 📄 Sheet: settings
    ///   🎯 Router#d3e4f | 📱 Path: [details]
    /// ]
    /// ```
    func debugPrintCompleteHierarchy() {
        switch rootRouter.loggingStyle {
        case .disabled:
            return
        case .hierarchical:
            rootRouter.debugPrintHierarchy()
        case .flat:
            rootRouter.debugPrintFlatHierarchy()
        }
    }
}

// MARK: - Private Debug Methods
private extension Router {
    
    /// Prints the router hierarchy as a flat array.
    func debugPrintFlatHierarchy() {
        var routers: [Router] = []
        collectRouters(into: &routers)
        
        print("Routers: [")
        for router in routers {
            let idSuffix = router.extractRouterIdSuffix()
            var components: [String] = ["\(DebugConstants.routerIcon) Router#\(idSuffix)"]
            
            if !router.navigationPath.isEmpty {
                let pathIds = router.navigationPath.map { $0.id }
                components.append("\(DebugConstants.pathIcon) Path: \(pathIds)")
            }
            
            if let sheet = router.presentingSheet {
                components.append("\(DebugConstants.sheetIcon) Sheet: \(sheet.id)")
            }
            
            if let fullScreen = router.presentingFullScreen {
                components.append("\(DebugConstants.fullScreenIcon) FullScreen: \(fullScreen.id)")
            }
            
            print("  " + components.joined(separator: " | "))
        }
        print("]")
    }
    
    /// Collects all routers in the hierarchy into an array.
    /// - Parameter routers: The array to collect routers into
    func collectRouters(into routers: inout [Router]) {
        routers.append(self)
        if let child = childRouter {
            child.collectRouters(into: &routers)
        }
    }
    
    /// Recursively prints the router hierarchy with proper tree formatting.
    /// - Parameters:
    ///   - level: The current depth level in the hierarchy
    ///   - prefix: The prefix string for proper tree formatting
    ///   - isLast: Whether this router is the last child at its level
    func debugPrintHierarchy(level: Int = 0, prefix: String = "", isLast: Bool = true) {
        let idSuffix = extractRouterIdSuffix()
        let nodeConnector = level == 0 ? "" : (isLast ? DebugConstants.lastBranchConnector : DebugConstants.middleBranchConnector)
        
        print("\(prefix)\(nodeConnector)\(DebugConstants.routerIcon) Router#\(idSuffix)")
        
        let contentIndent = calculateContentIndent(level: level, prefix: prefix, isLast: isLast)
        printRouterContent(indent: contentIndent)
        
        if let child = childRouter {
            child.debugPrintHierarchy(level: level + 1, prefix: contentIndent, isLast: true)
        }
    }
    
    /// Extracts a short, readable identifier from the router's ObjectIdentifier.
    /// - Returns: A 5-character hexadecimal string representing the router
    func extractRouterIdSuffix() -> String {
        let rawId = ObjectIdentifier(self).debugDescription
        let hexSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
        let hexScalars = rawId.unicodeScalars.filter { hexSet.contains($0) }
        let hexString = String(String.UnicodeScalarView(hexScalars))
        return String(hexString.suffix(DebugConstants.idSuffixLength))
    }
    
    /// Calculates the proper indentation for router content based on hierarchy level.
    /// - Parameters:
    ///   - level: The current depth level in the hierarchy
    ///   - prefix: The existing prefix string
    ///   - isLast: Whether this router is the last child at its level
    /// - Returns: The calculated indentation string
    func calculateContentIndent(level: Int, prefix: String, isLast: Bool) -> String {
        if level == 0 {
            return prefix + DebugConstants.rootIndent
        } else {
            return prefix + (isLast ? DebugConstants.emptyConnector : DebugConstants.verticalConnector)
        }
    }
    
    /// Prints the router's content (path, sheets, fullscreen) with the given indentation.
    /// - Parameter indent: The indentation string to use
    func printRouterContent(indent: String) {
        if !navigationPath.isEmpty {
            let pathIds = navigationPath.map { $0.id }
            print("\(indent)\(DebugConstants.pathIcon) Path: \(pathIds)")
        }
        
        if let sheet = presentingSheet {
            print("\(indent)\(DebugConstants.sheetIcon) Sheet: \(sheet.id)")
        }
        
        if let fullScreen = presentingFullScreen {
            print("\(indent)\(DebugConstants.fullScreenIcon) FullScreen: \(fullScreen.id)")
        }
    }
}
