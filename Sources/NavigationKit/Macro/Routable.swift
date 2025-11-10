//
//  Routable.swift
//  NavigationKit
//
//  Created by Ahmed Elmoughazy on 08.08.25
//  Copyright © 2025 Ahmed Elmoghazy. All rights reserved.
//

// MARK: - Navigation Macros

/// A macro that marks a SwiftUI View for automatic route generation.
///
/// This macro enables views to be discovered by the RouteGenerator build plugin
/// and included in the generated route enum. It provides automatic conformance to 
/// required protocols (Hashable, Identifiable) that enable type-safe navigation.
///
/// **Note:** The `Routable` protocol conformance added by this macro is deprecated 
/// but kept for backward compatibility. The Router now works with any View through 
/// type erasure.
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
/// - Protocol conformance for `Hashable`, `Equatable`, and `Identifiable`
/// - `==` operator for equality comparison based on a unique `id`
/// - `hash(into:)` function for hashing based on the same `id`
///
/// ## Code Generation
/// The RouteGenerator plugin scans for `@Routable` views and creates:
/// ```swift
/// enum Route: View {
///     case homeView
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
/// - SeeAlso: `Router` for navigation state management
//@attached(extension, conformances: Routable)
@attached(extension, conformances: Routable, names: named(==), named(hash(into:)))
public macro Routable() = #externalMacro(module: "NavigationKitMacro", type: "RoutableMacro")
