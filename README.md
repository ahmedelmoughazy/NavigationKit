# NavigationKit

A powerful, type-safe navigation system for SwiftUI applications that provides programmatic navigation with hierarchical state management and automatic route generation.

[![Swift](https://img.shields.io/badge/Swift-6.1+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2016.0%2B-blue.svg)](https://developer.apple.com/swift)
[![SPM](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager)

## Features

- ✨ **Type-Safe Navigation**: Strongly-typed routing with compile-time safety
- 🔄 **Hierarchical Navigation**: Automatic parent-child router management
- 📱 **Modal Presentations**: Built-in support for sheets and full-screen covers
- 🎯 **Programmatic Control**: Push, pop, present, and dismiss from anywhere
- 🤖 **Automatic Code Generation**: Generate route enums from annotated views
- 🔍 **Debug Support**: Comprehensive hierarchy logging for development
- ⚡️ **Reactive Updates**: Combine publishers for navigation state changes
- 🎨 **Animation Control**: Optional animation for all navigation actions

## Requirements

- iOS 16.0+
- Swift 6.1+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add NavigationKit to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/ahmedelmoughazy/NavigationKit.git", from: "1.0.0")
]
```

Then add it to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: ["NavigationKit"]
)
```

## Quick Start

### 1. Mark Your Views as Routable

Use the `@Routable` macro to mark views that should be part of your navigation system:

```swift
import SwiftUI
import NavigationKit

@Routable
struct HomeView: View {
    var body: some View {
        Text("Home")
    }
}

@Routable
struct ProfileView: View {
    let userId: String
    
    var body: some View {
        Text("Profile for user: \(userId)")
    }
}

@Routable
struct SettingsView: View {
    var body: some View {
        Text("Settings")
    }
}
```

### 2. Generate Routes

Run the route generation plugin to create your Route enum:

```bash
swift package plugin generate-navigation --name Route
```

This generates a `Route.swift` file with all your routable views:

```swift
public enum Route: Routable, View {
    case homeView
    case profileView(userId: String)
    case settingsView
    
    // ... generated code for view instantiation
}
```

### 3. Set Up Navigation

Create a router and wrap your root view with `BaseNavigation`:

```swift
import SwiftUI
import NavigationKit

@main
struct MyApp: App {
    @StateObject private var router = Router<Route>()
    
    var body: some Scene {
        WindowGroup {
            BaseNavigation(router: router) {
                Route.homeView
            }
        }
    }
}
```

### 4. Navigate

Access the router from any view using `@EnvironmentObject` and navigate programmatically:

```swift
struct HomeView: View {
    @EnvironmentObject var router: Router<Route>
    
    var body: some View {
        VStack {
            Button("Go to Profile") {
                router.push(destination: .profileView(userId: "123"))
            }
            
            Button("Open Settings as Sheet") {
                router.present(destination: .settingsView, as: .sheet)
            }
        }
    }
}
```

## Usage Guide

### Router API

#### Stack Navigation

```swift
// Push a new destination
router.push(destination: .profileView(userId: "123"))

// Pop the current view
router.pop()

// Pop to a specific destination
router.pop(to: .homeView)

// Pop to presentation (clear current stack)
router.popToPresentation()

// Pop all and dismiss all modals
router.popAll()
```

#### Modal Presentation

```swift
// Present as sheet
router.present(destination: .settingsView, as: .sheet)

// Present as full-screen cover
router.present(destination: .detailView, as: .fullScreenCover)

// Dismiss current modal
router.dismiss()
```

#### Advanced Navigation

```swift
// Insert destination at specific index
router.insert(destination: .homeView, at: 0)

// Remove specific destinations
router.remove(destinations: .profileView(userId: "123"))

// Replace entire navigation path
router.applyPath([.homeView, .profileView(userId: "456")])
```

#### Animation Control

All navigation methods support optional animation control:

```swift
router.push(destination: .profileView(userId: "123"), animated: false)
router.pop(animated: false)
router.present(destination: .settingsView, as: .sheet, animated: false)
```

### Route Tracking

Monitor navigation state changes reactively:

```swift
// Get current route
let currentRoute: [String] = router.currentRoute

// Subscribe to route changes
router.currentRoutePublisher
    .sink { route in
        print("Navigation changed: \(route)")
    }
    .store(in: &cancellables)
```

### Alert System

NavigationKit includes a built-in alert system that works seamlessly with modal presentations.

#### Why a Custom Alert System?

When using standard SwiftUI alert modifiers alongside sheet or full-screen cover presentations, showing an alert can cause the modal presentation to be dismissed unexpectedly. This is a known SwiftUI behavior where alert presentation can interfere with modal lifecycle management.

NavigationKit's alert system solves this problem by:
- **Modal-Safe Presentation**: Alerts won't dismiss sheets or full-screen covers
- **State Management**: Properly integrated with the navigation hierarchy
- **Alert Replacement**: Seamlessly replace one alert with another
- **Automatic Cleanup**: Properly synchronizes state with the router

#### Usage

Present alerts through the router's `alertItem` property:

```swift
struct MyView: View {
    @EnvironmentObject var router: Router<Route>
    
    var body: some View {
        Button("Show Alert") {
            router.alertItem = AlertItem(
                title: "Confirmation",
                message: "Are you sure?",
                actionButtons: [
                    AlertActionButton(title: "Confirm", style: .primary) {
                        // Handle confirmation
                    },
                    AlertActionButton(title: "Cancel", style: .cancel)
                ]
            )
        }
    }
}
```

#### Alert Button Styles

NavigationKit provides four button styles to match your alert's intent:

- **`.primary`**: The main action (emphasized with keyboard shortcut)
- **`.secondary`**: Alternative actions (default style)
- **`.destructive`**: Dangerous actions like delete
- **`.cancel`**: Dismisses without action

#### Dismissing Alerts

Alerts are automatically dismissed when:
- The user taps any action button
- You set `router.alertItem = nil` programmatically

```swift
// Manually dismiss an alert
router.alertItem = nil
```

## Advanced Features

### Routable Protocol

The `Routable` protocol is the foundation of NavigationKit. It combines several protocols to enable type-safe navigation:

```swift
public protocol Routable: Hashable, Equatable, Identifiable<String>, View {
    var id: ID { get }
}
```

Views can conform manually or use the `@Routable` macro for automatic conformance.

### Router Hierarchy

NavigationKit automatically manages a hierarchy of routers:

- **Root Router**: Manages the main navigation stack
- **Child Routers**: Created automatically for modal presentations
- **Active Router**: Always points to the currently active router in the hierarchy

```swift
// Get the root router
let root = router.rootRouter

// Get the active router (for modal context)
let active = router.activeRouter
```

### Debug Logging

In DEBUG builds, NavigationKit provides comprehensive hierarchy logging:

```swift
#if DEBUG
router.debugPrintCompleteHierarchy()
#endif
```

Output example:
```
🎯 Router#a1b2c
  📱 Path: [homeView, profileView]
  📄 Sheet: settingsView
  └── 🎯 Router#d3e4f
      📱 Path: [detailView]
```

### Code Generation Plugin

The route generator supports custom route names:

```bash
# Generate with custom name
swift package plugin generate-navigation --name AppRoute

# Generate default Route enum
swift package plugin generate-navigation
```

The plugin:
- Scans all Swift files for `@Routable` views
- Extracts view parameters from initializers
- Generates enum cases with associated values
- Creates view instantiation logic
- Handles default parameters and environment objects

## Best Practices

1. **Use the @Routable Macro**: Prefer the macro over manual conformance for consistency and reduced boilerplate.

2. **Environment Objects**: Views can use `@EnvironmentObject` for dependencies—these are automatically excluded from route parameters.

3. **Organized Navigation**: Create a dedicated `Route` enum per major feature or module for better organization.

4. **State Management**: Keep navigation state separate from view state—the router manages navigation, views manage content.

5. **Testing**: Use the router's published properties to test navigation flows without UI.

## Architecture

NavigationKit is built on several key components:

- **Router**: Observable state manager with Combine publishers
- **BaseNavigation**: SwiftUI container with NavigationStack integration
- **Routable Protocol**: Type requirements for navigation destinations
- **@Routable Macro**: Swift macro for automatic conformance
- **RouteGenerator**: Build-time code generator
- **GenerateRoutes Plugin**: SPM command plugin

## Examples

### Complex Navigation Flow

```swift
@Routable
struct ProductListView: View {
    @EnvironmentObject var router: Router<Route>
    
    var body: some View {
        List(products) { product in
            Button(product.name) {
                router.push(destination: .productDetailView(productId: product.id))
            }
        }
        .navigationTitle("Products")
        .toolbar {
            Button("Cart") {
                router.present(destination: .cartView, as: .sheet)
            }
        }
    }
}

@Routable
struct ProductDetailView: View {
    let productId: String
    @EnvironmentObject var router: Router<Route>
    
    var body: some View {
        VStack {
            // Product details...
            
            Button("Buy Now") {
                // Complete purchase then navigate to confirmation
                router.applyPath([
                    .productListView,
                    .orderConfirmationView(orderId: "456")
                ])
            }
        }
    }
}
```

### Conditional Navigation

```swift
struct LoginView: View {
    @EnvironmentObject var router: Router<Route>
    @State private var isLoggedIn = false
    
    var body: some View {
        Button("Login") {
            // Perform login...
            if isLoggedIn {
                router.push(destination: .homeView)
            } else {
                router.alertItem = AlertItem(
                    title: "Login Failed",
                    message: "Invalid credentials",
                    actionButtons: [
                        AlertActionButton(title: "OK", style: .cancel)
                    ]
                )
            }
        }
    }
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

NavigationKit is available under the MIT license. See the LICENSE file for more info.

## Author

Ahmed Elmoughazy - [@ahmedelmoughazy](https://github.com/ahmedelmoughazy)

## Acknowledgments

Built with Swift Macros and SwiftSyntax for powerful compile-time code generation.
