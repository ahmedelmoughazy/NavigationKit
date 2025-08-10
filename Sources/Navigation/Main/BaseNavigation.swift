import Foundation
import SwiftUI

public struct BaseNavigation<Content: View>: View {
        
    public init(
        router: Router,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._router = .init(initialValue: router)
        self.content = content
    }
    
    public var body: some View {
        NavigationStack(path: $router.navigationPath) {
            content()
                .navigationDestination(for: AnyRoutable.self) { $0.makeView() }
        }
        .environment(\.router, router)
        .sheet(item: $router.presentingSheet) {
            sheet(for: $0, from: router)
        }
        .fullScreenCover(item: $router.presentingFullScreen) {
            fullScreenCover(for: $0, from: router)
        }
        .onChange(of: router.currentPath) { _, newValue in
            print(newValue.map { $0.id.description })
        }
    }
    
    func sheet(for destination: AnyRoutable, from router: Router) -> some View {
        let router = Router()
        router.parentRouter = self.router
        return BaseNavigation<AnyView>(router: router) { destination.makeView() }
    }

    func fullScreenCover(for destination: AnyRoutable, from router: Router) -> some View {
        let router = Router()
        router.parentRouter = self.router
        return BaseNavigation<AnyView>(router: router) { destination.makeView() }
    }
    
    @State
    private var router: Router
    
    @ViewBuilder
    private let content: () -> Content
}
