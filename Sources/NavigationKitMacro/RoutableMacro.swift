//
//  RoutableMacro.swift
//  NavigationKit
//
//  Created by Ahmed Elmoughazy on 08.08.25
//  Copyright © 2025 Ahmed Elmoghazy. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: - Compiler Plugin

/// Main compiler plugin that provides the @Routable macro to the Swift compiler.
///
/// This plugin registers the RoutableMacro implementation with the Swift compiler,
/// enabling the use of @Routable annotations in Swift source code for automatic
/// navigation route generation.
@main
struct RoutableMacroPlugin: CompilerPlugin {
    
    /// Array of macro types provided by this plugin
    let providingMacros: [Macro.Type] = [
        RoutableMacro.self,
    ]
}

// MARK: - Routable Macro

/// Implementation of the @Routable macro for marking SwiftUI views as navigable.
///
/// This macro enables automatic code generation for navigation routes by marking
/// SwiftUI views that should be included in the generated Route enum.
/// The macro itself doesn't generate code directly but serves as a marker for
/// the RouteGenerator tool.
///
/// Usage:
/// ```swift
/// @Routable
/// struct ProfileView: View {
///     let userId: String
///     
///     var body: some View {
///         // View implementation
///     }
/// }
/// ```
///
/// This macro now generates the following:
/// - `Routable` protocol conformance
/// - `==` operator for equality comparison based on a unique `id`
/// - `hash(into:)` function for hashing based on the same `id`
public struct RoutableMacro: MemberMacro, ExtensionMacro {
    
    // MARK: - ExtensionMacro Implementation
    
    /// Provides protocol conformance extensions for types marked with @Routable.
    ///
    /// This method is called by the Swift compiler when the @Routable macro is applied
    /// to a type. It can automatically add protocol conformances to the marked type.
    ///
    /// - Parameters:
    ///   - node: The attribute syntax node representing the @Routable macro
    ///   - declaration: The declaration group (struct/class) that the macro is attached to
    ///   - type: The type syntax representing the type being extended
    ///   - protocols: Array of protocol types to conform to
    ///   - context: The macro expansion context providing compilation information
    /// - Returns: Array of extension declarations to be added to the type
    /// - Throws: NavigationMacroError if the macro is applied incorrectly
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        // Create extension with the property
        let extensionDecl = try ExtensionDeclSyntax(
        """
        extension \(type): Routable {
            public static func == (lhs: \(type), rhs: \(type)) -> Bool {
                return lhs.id == rhs.id
            }

            public func hash(into hasher: inout Hasher) {
                hasher.combine(id)
            }
        }
        """
        )
        
        return [extensionDecl]
    }
}

// MARK: - Error Handling

/// Errors that can occur during @Routable macro processing.
///
/// This enum defines the possible error conditions that can arise when
/// the @Routable macro is applied incorrectly or in unsupported contexts.
public enum NavigationMacroError: Error, CustomStringConvertible {
    
    /// Error thrown when @Routable is applied to non-struct declarations
    case onlyApplicableToStructs
    
    /// Human-readable description of the error
    public var description: String {
        switch self {
        case .onlyApplicableToStructs:
            return MacroErrorMessages.structOnlyMessage
        }
    }
}

// MARK: - Constants

/// Constants for macro error messages
private enum MacroErrorMessages {
    static let structOnlyMessage = "@Routable can only be applied to struct declarations"
}
