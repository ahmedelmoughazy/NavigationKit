# NavigationKit

A lightweight navigation system for SwiftUI applications that provides programmatic navigation with hierarchical state management.

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2016.0%2B-blue.svg)](https://developer.apple.com/swift)
[![SPM](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager)

## Features

- **Type-Safe Navigation**: Strongly-typed routing with compile-time safety
- **Layered Navigation**: Present views on top of each other, modals within modals, all managed automatically
- **Modal Presentations**: Built-in support for sheets and full-screen covers
- **Programmatic Control**: Push, pop, present, and dismiss from anywhere
- **Debug Support**: Comprehensive hierarchy logging for development
- **Reactive Updates**: Combine publishers for navigation state changes
- **Animation Control**: Optional animation for all navigation actions

## Requirements

- iOS 16.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add NavigationKit to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/ahmedelmoughazy/NavigationKit.git", from: "0.1.1")
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

### 1. Create Your Views

Mark your views with the `@Routable` macro:

```swift
import SwiftUI
import NavigationKit

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

### 2. Set Up Navigation

Create a router and wrap your root view with `BaseNavigation`:

```swift
import SwiftUI
import NavigationKit

@main
struct MyApp: App {
    private let router = Router()
    
    var body: some Scene {
        WindowGroup {
            BaseNavigation(router: router) {
                RootView()
            }
        }
    }
}
```

### 3. Navigate

Access the router from any view using `@EnvironmentObject` and navigate programmatically:

```swift
struct RootView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack {
            Button("Go to Profile") {
                router.push(destination: ProfileView(userId: "123"))
            }
            
            Button("Open Settings as Sheet") {
                router.present(destination: SettingsView(), as: .sheet)
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
router.push(destination: ProfileView(userId: "123"))

// Pop the current view
router.pop()

// Pop to a specific destination
router.pop(to: HomeView())

// Pop to presentation (clear current stack)
router.popToPresentation()

// Pop all and dismiss all modals
router.popAll()
```

#### Modal Presentation

```swift
// Present as sheet
router.present(destination: SettingsView(), as: .sheet)

// Present as full-screen cover
router.present(destination: DetailView(), as: .fullScreenCover)

// Dismiss current modal
router.dismiss()
```

#### Advanced Navigation

```swift
// Insert destination at specific index
router.insert(destination: HomeView(), at: 0)

// Remove specific destinations
router.remove(destinations: ProfileView(userId: "123"))

// Replace entire navigation path
router.applyPath([HomeView(), ProfileView(userId: "456")])
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
            router.presentAlert(alertItem: AlertItem(
                    title: "Confirmation",
                    message: "Are you sure?",
                    actionButtons: [
                        AlertActionButton(title: "Confirm", style: .primary) {
                            // Handle confirmation
                        },
                        AlertActionButton(title: "Cancel", style: .cancel)
                    ]
                )
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
- The user taps any action button.
- You call `router.dismissAlert()`.

## Advanced Features

### Debug Logging

NavigationKit provides powerful logging capabilities to help debug navigation flows.

#### Configuring Logging

Set the logging style when creating the router:

```swift
// Disable logging (default)
let router = Router(loggingStyle: .disabled)

// Enable hierarchical logging (tree view)
let router = Router(loggingStyle: .hierarchical)

// Enable flat logging (array view)
let router = Router(loggingStyle: .flat)
```

When logging is enabled, the navigation hierarchy is automatically printed whenever navigation state changes.

#### Logging Styles

**Disabled** (default) - No logging output

**Hierarchical** - Tree view with indentation:
```
🎯 Router#a1b2c
  📱 Path: [home, profile]
  📄 Sheet: settings
  └── 🎯 Router#d3e4f
      📱 Path: [details]
```

**Flat** - Array view with sequential listing:
```
Routers: [
  🎯 Router#a1b2c | 📱 Path: [home, profile] | 📄 Sheet: settings
  🎯 Router#d3e4f | 📱 Path: [details]
]
```

#### Dynamic Configuration

You can change the logging style at any time:

```swift
// Switch to hierarchical logging
router.loggingStyle = .hierarchical

// Disable logging
router.loggingStyle = .disabled
```

#### Manual Logging

You can also manually trigger logging at any time:

```swift
router.debugPrintCompleteHierarchy()
```

## Best Practices

1. **Use @Routable Macro**: Apply the macro to all views you want to navigate to.

2. **Inject Router**: Access the router via `@EnvironmentObject` in views that need navigation.

3. **State Management**: Keep navigation state separate from view state—the router manages navigation, views manage content.

4. **Testing**: Use the router's published properties to test navigation flows without UI.

## Examples

### Complex Navigation Flow

```swift
@Routable
struct ProductListView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        List(products) { product in
            Button(product.name) {
                router.push(destination: ProductDetailView(productId: product.id))
            }
        }
        .navigationTitle("Products")
        .toolbar {
            Button("Cart") {
                router.present(destination: CartView(), as: .sheet)
            }
        }
    }
}

@Routable
struct ProductDetailView: View {
    let productId: String
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack {
            // Product details...
            
            Button("Buy Now") {
                // Complete purchase then navigate to confirmation
                router.applyPath([
                    ProductListView(),
                    OrderConfirmationView(orderId: "456")
                ])
            }
        }
    }
}
```

### Conditional Navigation

```swift
struct LoginView: View {
    @EnvironmentObject var router: Router
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
