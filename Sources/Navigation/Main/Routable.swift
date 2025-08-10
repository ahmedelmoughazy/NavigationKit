import SwiftUI

public protocol Routable: View {
    /// Unique identifier for this route
    nonisolated static var routeId: String { get }
}

public extension Routable {
    static var routeId: String {
        String(describing: Self.self)
    }
}
