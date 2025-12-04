import SwiftUI

/// A type-erased wrapper for navigation destinations that conform to `Routable`.
///
/// `AnyDestination` provides type erasure for SwiftUI views used in navigation,
/// allowing the Router to manage heterogeneous destination types in a single
/// navigation path. It wraps any `Routable` view and provides identity and hashability
/// required for NavigationStack integration.
///
/// ## Purpose
/// - Enables storing different `Routable` view types in the same navigation path array
/// - Provides unique identification through the `Routable` protocol's `id` property
/// - Supports presentation customization through detents
///
/// ## Usage
/// This type is used internally by the Router and is typically not
/// created directly by application code. The Router automatically wraps
/// `Routable` views when they are pushed or presented.
///
/// - Note: Identity comes from the `Routable` protocol's `id` property
/// - SeeAlso: `Router` for navigation state management
/// - SeeAlso: `Routable` protocol for view requirements
struct AnyDestination: Hashable, Identifiable {
    /// Unique identifier based on the destination view's type.
    let id: String
    
    /// The type-erased view to be displayed.
    let view: AnyView
    
    /// The set of presentation detents (e.g., sheet sizes) for modal presentation.
    let presentationDetents: Set<PresentationDetent>
    
    /// Creates a type-erased destination from any SwiftUI view.
    ///
    /// - Parameters:
    ///   - route: The view to wrap as a navigation destination
    ///   - presentationDetents: The presentation detents for modal presentations (default: .large)
    init<R: Routable>(_ route: R, presentationDetents: Set<PresentationDetent> = [.large]) {
        self.id = route.id
        self.view = AnyView(route)
        self.presentationDetents = presentationDetents
    }
    
    /// Compares two destinations for equality based on their unique identifiers.
    ///
    /// Two destinations are considered equal if they wrap the same view type,
    /// regardless of the view's content or parameters.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side destination
    ///   - rhs: The right-hand side destination
    /// - Returns: `true` if both destinations have the same identifier
    static func == (lhs: AnyDestination, rhs: AnyDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Hashes the destination's unique identifier.
    ///
    /// - Parameter hasher: The hasher to use for combining the identifier
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
