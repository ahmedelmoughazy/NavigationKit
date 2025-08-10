//
//  NavigationMacro.swift
//  SwiftUINavigation
//
//  Created by Ahmed Elmoughazy on 08.08.25.
//


import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Macro implementation for @Routable
public struct RoutableMacro: MemberMacro, ExtensionMacro {

    // ExtensionMacro implementation
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        let confirmations = protocols.map { $0.trimmed.description }.joined(separator: ", ")
        let extensionDecl = try ExtensionDeclSyntax("extension \(type): \(raw: confirmations) { }")
        return [extensionDecl]
    }

}

public enum NavigationMacroError: Error, CustomStringConvertible {
    case onlyApplicableToStructs
    
    public var description: String {
        switch self {
        case .onlyApplicableToStructs:
            return "@Routable can only be applied to struct declarations"
        }
    }
}

@main
struct RoutableMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RoutableMacro.self,
    ]
}
