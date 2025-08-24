//
//  ViewInfo.swift
//  Navigation
//
//  Created by Ahmed Elmoughazy on 20.08.25.
//

import Foundation

// MARK: - ViewInfo

/// Represents information about a SwiftUI view that can be used for navigation route generation.
///
/// This struct encapsulates all the necessary information to generate navigation enum cases
/// and switch statements for a routable view, including the view name and its parameters.
struct ViewInfo {
    
    // MARK: - Properties
    
    /// The name of the SwiftUI view (e.g., "ProfileView")
    let name: String
    
    /// Array of parameters required to initialize the view
    let parameters: [Parameter]
    
    // MARK: - Computed Properties
    
    /// Generates the enum case name in camelCase format.
    ///
    /// Converts the view name from PascalCase to camelCase for use in enum declarations.
    /// For example: "ProfileView" becomes "profileView"
    ///
    /// - Returns: The camelCase version of the view name
    var enumCaseName: String {
        name.prefix(1).lowercased() + name.dropFirst()
    }
    
    /// Generates the complete enum case declaration string.
    ///
    /// Creates either a simple case declaration or one with associated values
    /// depending on whether the view has parameters.
    ///
    /// - Returns: A string like "case profileView" or "case profileView(userId: String, isEditable: Bool)"
    var enumCaseDeclaration: String {
        if parameters.isEmpty {
            return "case \(enumCaseName)"
        } else {
            let params = parameters.map { "\($0.name): \($0.type)" }.joined(separator: ", ")
            return "case \(enumCaseName)(\(params))"
        }
    }
    
    /// Generates the switch case for view instantiation.
    ///
    /// Creates the switch case statement that instantiates the actual SwiftUI view
    /// with the appropriate parameter bindings.
    ///
    /// - Returns: A string like "case .profileView: ProfileView()" or "case .profileView(let userId, let isEditable): ProfileView(userId: userId, isEditable: isEditable)"
    var switchCase: String {
        if parameters.isEmpty {
            return "case .\(enumCaseName): \(name)()"
        } else {
            let bindings = parameters.map { "let \($0.name)" }.joined(separator: ", ")
            let params = parameters.map { "\($0.name): \($0.name)" }.joined(separator: ", ")
            return "case .\(enumCaseName)(\(bindings)): \(name)(\(params))"
        }
    }
    
    /// Generates the switch case for string description.
    ///
    /// Creates the switch case for the CustomStringConvertible implementation
    /// that returns a human-readable description of the route.
    ///
    /// - Returns: A string like "case .profileView: \"profileView\""
    var switchCaseDescription: String {
        "case .\(enumCaseName): \"\(enumCaseName)\""
    }
}

// MARK: - ViewInfo.Parameter

extension ViewInfo {
    
    /// Represents a parameter of a SwiftUI view that affects route generation.
    ///
    /// Contains all necessary information about a view parameter including its name,
    /// type, and whether it has a default value (which affects whether it's required
    /// in the navigation route).
    struct Parameter {
        
        // MARK: - Properties
        
        /// The parameter name as it appears in the view's initializer
        let name: String
        
        /// The Swift type of the parameter (e.g., "String", "Int", "Bool")
        let type: String
        
        /// Whether this parameter has a default value in the view's initializer
        let hasDefaultValue: Bool
    }
}
