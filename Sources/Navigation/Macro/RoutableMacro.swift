//
//  RoutableMacro.swift
//  Navigation
//
//  Created by Ahmed Elmoughazy on 08.08.25.
//

/// Macro that makes a SwiftUI View routable
/// Automatically adds protocol conformance and generates route information
@attached(extension, conformances: Routable)
public macro Routable() = #externalMacro(module: "NavigationMacro", type: "RoutableMacro")
