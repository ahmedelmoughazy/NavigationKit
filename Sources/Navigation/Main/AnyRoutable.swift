import SwiftUI

/// A type-erased, hashable, and identifiable route
public struct AnyRoutable: Hashable, Identifiable {
    private let viewBuilder: () -> AnyView
    public let id: String
    
    public init<R: Routable>(_ route: R) {
        self.id = type(of: route).routeId
        self.viewBuilder = { AnyView(route) }
    }
    
    public static func == (lhs: AnyRoutable, rhs: AnyRoutable) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func makeView() -> AnyView {
        viewBuilder()
    }
}
