// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "NavigationKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "NavigationKit",
            targets: ["NavigationKit"]
        )
        //,
        // Temporarily disabled - uncomment to re-enable route generation
        // .plugin(
        //     name: "GenerateRoutes",
        //     targets: ["Generate routes"]
        // )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "600.0.0-latest"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "NavigationKit",
            dependencies: ["NavigationKitMacro"]
        ),
        .macro(
            name: "NavigationKitMacro",
            dependencies: [
                .product(
                    name: "SwiftSyntaxMacros",
                    package: "swift-syntax"
                ),
                .product(
                    name: "SwiftCompilerPlugin",
                    package: "swift-syntax"
                )
            ]
        ),
        .executableTarget(
            name: "RouteGenerator"
        ),
        .plugin(
            name: "Generate routes",
            capability: .command(
                intent: .custom(
                    verb: "generate-navigation",
                    description: "Generate navigation routes from @Routable views"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "Create file for navigation route")
                ]
            ),
            dependencies: ["RouteGenerator"],
            path: "Plugins/GenerateRoutes"
        ),
        .testTarget(
            name: "NavigationKitTests",
            dependencies: ["NavigationKit"]
        )
    ]
)
