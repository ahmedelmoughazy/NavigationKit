//
//  RoutableProtocol.swift
//  Navigation
//
//  Created by Ahmed Elmoughazy on 08.08.25
//  Copyright © 2025 Ahmed Elmoghazy. All rights reserved.
//

import SwiftUI

// MARK: - Routable Protocol

/// A protocol that marks SwiftUI views as routable within the navigation system.
///
/// Views conforming to `Routable` are eligible for automatic route generation and
/// can be used as destinations in the navigation system. The protocol serves as a
/// marker interface that enables the code generation tools to identify and process
/// views for inclusion in the navigation route enum.
///
/// ## Automatic Route Generation
///
/// When a view conforms to `Routable`, the RouteGenerator build plugin
/// will automatically:
/// - Include the view in the generated `Route` enum
/// - Generate appropriate enum cases with required parameters
/// - Create view instantiation logic
/// - Handle navigation path management
///
/// ## Manual Conformance
///
/// Views can conform to `Routable` manually:
/// ```swift
/// struct HomeView: View, Routable {
///     var body: some View {
///         Text("Home")
///     }
/// }
/// ```
///
/// ## Macro-Based Conformance
///
/// The preferred approach is using the `@Routable` macro:
/// ```swift
/// @Routable
/// struct ProfileView: View {
///     let userId: String
///     
///     var body: some View {
///         Text("Profile for \(userId)")
///     }
/// }
/// ```
///
/// ## Requirements
///
/// - Must be a SwiftUI `View`
/// - Should have a public or internal access level for route generation
/// - Any required initializer parameters will be included in the generated routes
/// - Environment objects and computed properties are automatically excluded
/// - Includes `==` operator and `hash(into:)` function for `Hashable` and `Equatable` conformance
///
/// ## Generated Routes
///
/// For a view with parameters, the generator creates:
/// ```swift
/// enum Route {
///     case profileView(userId: String)
///     
///     var body: some View {
///         switch self {
///         case .profileView(let userId):
///             ProfileView(userId: userId)
///         }
///     }
/// }
/// ```
///
/// - Note: This protocol works in conjunction with the RouteGenerator build plugin
/// - SeeAlso: `@Routable` macro for automatic conformance
/// - SeeAlso: `Router` for navigation state management
public protocol Routable: Hashable, Equatable, Identifiable<String>, View {
    var id: ID { get }
}

public extension Routable {
    var id: ID { String(describing: Self.self) }
}
