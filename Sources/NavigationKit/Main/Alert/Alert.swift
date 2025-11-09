//
//  Alert.swift
//  NavigationKit
//
//  Created by Ahmed Elmoughazy on 09.11.25.
//  Copyright © 2025 Ahmed Elmoghazy. All rights reserved.
//

import SwiftUI

// MARK: - View Extension

internal extension View {
    /// Presents alerts that are compatible with NavigationKit's modal presentation system.
    ///
    /// This modifier prevents alerts from causing unexpected dismissals of sheets or full-screen covers.
    /// It's automatically applied by `BaseNavigation` and works with `router.alertItem`.
    ///
    /// - Parameter alertItem: A binding to an optional AlertItem that controls alert presentation
    /// - Returns: A view with the alert modifier applied
    ///
    /// - Note: Applied automatically by BaseNavigation; set `router.alertItem` to present alerts
    /// - SeeAlso: `AlertItem` for creating alert configurations
    func alert(alertItem: Binding<AlertItem?>) -> some View {
        modifier(AlertModifier(alertItem: alertItem))
    }
}
