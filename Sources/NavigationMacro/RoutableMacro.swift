//
//  RoutableMacro.swift
//  Navigation
//
//  Created by Ahmed Elmoughazy on 08.08.25.
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
/// SwiftUI views that should be included in the generated NavigationRoute enum.
/// The macro itself doesn't generate code directly but serves as a marker for
/// the NavigationCodeGenerator tool.
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
        
        // Join protocol conformances into a single string
        let confirmations = protocols.map { $0.trimmed.description }.joined(separator: ", ")
        
        // Generate extension declaration
        let extensionDecl = try ExtensionDeclSyntax("extension \(type): \(raw: confirmations) { }")
        
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
