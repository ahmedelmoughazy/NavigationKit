// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Navigation",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v17),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Navigation",
            targets: ["Navigation"]
        ),
        .plugin(
            name: "NavigationPlugin",
            targets: ["NavigationPlugin"]
        )
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
            name: "Navigation",
            dependencies: ["NavigationMacro"]
        ),
        .macro(
            name: "NavigationMacro",
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
            name: "NavigationCodeGenerator"
        ),
        .plugin(
            name: "NavigationPlugin",
            capability: .command(
                intent: .custom(
                    verb: "generate-navigation",
                    description: "Generate navigation routes from @Routable views"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "Create file for navigation route")
                ]
            ),
            dependencies: ["NavigationCodeGenerator"]
        ),
        .testTarget(
            name: "NavigationTests",
            dependencies: ["Navigation"]
        )
    ]
)
