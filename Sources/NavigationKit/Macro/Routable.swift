//
//  Routable.swift
//  NavigationKit
//
//  Created by Ahmed Elmoughazy on 08.08.25
//  Copyright © 2025 Ahmed Elmoghazy. All rights reserved.
//

// MARK: - Navigation Macros

/// A macro that marks a SwiftUI View as routable within the navigation system.
///
/// This macro automatically adds `Routable` protocol conformance to the annotated view,
/// enabling it to be used with the navigation system's automatic route generation.
/// The code generator will scan for views marked with this macro and include them
/// in the generated `Route` enum.
///
/// ## Usage
/// ```swift
/// @Routable
/// struct HomeView: View {
///     var body: some View {
///         Text("Home")
///     }
/// }
/// ```
///
/// ## Requirements
/// - The annotated type must be a SwiftUI `View`
/// - The view should have a public or internal access level
/// - Any required initializer parameters will be included in the generated route enum
///
/// ## Generated Code
/// The macro generates:
/// - `Routable` protocol conformance
/// - `==` operator for equality comparison based on a unique `id`
/// - `hash(into:)` function for hashing based on the same `id`
///
/// ## Code Generation
/// The RouteGenerator plugin scans for `@Routable` views and creates:
/// ```swift
/// enum Route: Routable, View {
///     case homeView
///     
///     public var id: String {
///         switch self {
///         case .homeView: return "homeView"
///         }
///     }
///     
///     var body: some View {
///         switch self {
///         case .homeView:
///             HomeView()
///         }
///     }
/// }
/// ```
///
/// - Note: This macro works in conjunction with the RouteGenerator build plugin
/// - SeeAlso: `Routable` protocol for manual conformance
/// - SeeAlso: `Router` for navigation state management
//@attached(extension, conformances: Routable)
@attached(extension, conformances: Routable, names: named(==), named(hash(into:)))
public macro Routable() = #externalMacro(module: "NavigationKitMacro", type: "RoutableMacro")
