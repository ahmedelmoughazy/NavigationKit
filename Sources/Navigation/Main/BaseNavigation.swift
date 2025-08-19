import Foundation
import SwiftUI

public struct BaseNavigation<Content: View, Destination: Hashable & Identifiable & CustomStringConvertible & View>: View {
        
    public init(
        router: Router<Destination>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._router = .init(wrappedValue: router)
        self.content = content
    }
    
    public var body: some View {
        NavigationStack(path: $router.navigationPath) {
            content()
                .navigationDestination(for: Destination.self) { $0 }
        }
        .environmentObject(router)
        .sheet(item: $router.presentingSheet) {
            sheet(for: $0, from: router)
        }
        .fullScreenCover(item: $router.presentingFullScreen) {
            fullScreenCover(for: $0, from: router)
        }
        .onChange(of: router.navigationPath) { _, _ in
            // Notify hierarchy subscribers and debug-print once from root
            router.debugPrintHierarchyFromRoot()
        }
        .onChange(of: router.presentingSheet) { _, _ in
            // Notify hierarchy subscribers and debug-print once from root
            router.debugPrintHierarchyFromRoot()
        }
        .onChange(of: router.presentingFullScreen) { _, _ in
            // Notify hierarchy subscribers and debug-print once from root
            router.debugPrintHierarchyFromRoot()
        }
    }
    
    func sheet(for destination: Destination, from router: Router<Destination>) -> some View {
        let childRouter = Router<Destination>()
        self.router.childRouter = childRouter
        childRouter.parentRouter = self.router
        return BaseNavigation<AnyView, Destination>(router: childRouter) { AnyView(destination) }
    }

    func fullScreenCover(for destination: Destination, from router: Router<Destination>) -> some View {
        let childRouter = Router<Destination>()
        self.router.childRouter = childRouter
        childRouter.parentRouter = self.router
        return BaseNavigation<AnyView, Destination>(router: childRouter) { AnyView(destination) }
    }
    
    @StateObject
    private var router: Router<Destination>
    
    @ViewBuilder
    private let content: () -> Content
}
