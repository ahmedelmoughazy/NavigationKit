//
//  RoutableProtocol.swift
//  NavigationKit
//
//  Created by Ahmed Elmoughazy on 08.08.25
//  Copyright © 2025 Ahmed Elmoghazy. All rights reserved.
//

import SwiftUI

// MARK: - Routable Protocol

/// A protocol that marks SwiftUI views for automatic route generation.
///
/// **Note:** This protocol is deprecated and no longer required for navigation. 
/// The Router now uses type erasure and works directly with any View that conforms 
/// to Hashable and Identifiable. This protocol is kept for backward compatibility 
/// and will be removed in a future version.
///
/// ## Automatic Route Generation
///
/// The RouteGenerator build plugin scans for views marked with `@Routable` macro:
/// - Include the view in the generated route enum
/// - Generate appropriate enum cases with required parameters
/// - Create view instantiation logic
/// - Handle navigation path management
///
/// ## Manual Conformance (Deprecated)
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
/// ## Macro-Based Conformance (Recommended)
///
/// Use the `@Routable` macro for code generation:
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
///
/// ## Generated Routes
///
/// For a view with parameters, the generator creates:
/// ```swift
/// enum Route: View {
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
@available(*, deprecated, message: "Routable protocol is no longer required. Router now works with any View conforming to Hashable and Identifiable.")
public protocol Routable: Hashable, Equatable, Identifiable<String>, View {
    var id: ID { get }
}

public extension Routable {
    var id: ID { String(describing: Self.self) }
}
