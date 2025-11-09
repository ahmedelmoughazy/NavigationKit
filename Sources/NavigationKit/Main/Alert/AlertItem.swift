//
//  AlertItem.swift
//  NavigationKit
//
//  Created by Ahmed Elmoughazy on 09.11.25.
//  Copyright © 2025 Ahmed Elmoghazy. All rights reserved.
//

import SwiftUI

// MARK: - AlertItem

/// Represents an alert that can be presented through the navigation system.
///
/// Provides navigation-safe alert presentation that won't dismiss sheets or full-screen covers.
/// Present using `router.presentAlert(_:)` or set `router.alertItem` directly.
///
/// ```swift
/// router.presentAlert(AlertItem(
///     title: "Delete Item",
///     message: "Are you sure?",
///     actionButtons: [
///         AlertActionButton(title: "Delete", style: .destructive) { deleteItem() },
///         AlertActionButton(title: "Cancel", style: .cancel)
///     ]
/// ))
/// ```
///
/// - SeeAlso: `AlertActionButton` for configuring alert buttons
/// - SeeAlso: `Router.presentAlert(_:animated:)` for presenting alerts
/// - SeeAlso: `Router.dismissAlert(animated:)` for dismissing alerts
public struct AlertItem: Equatable {
    
    // MARK: - Properties
    
    /// The title text displayed at the top of the alert.
    public let title: String
    
    /// The message text displayed below the title.
    public var message: String
    
    /// The action buttons displayed in the alert.
    ///
    /// Button order and styling (primary, secondary, destructive, cancel) affect presentation.
    public var actionButtons: [AlertActionButton]
    
    // MARK: - Initialization
    
    /// Creates a new alert item with the specified configuration.
    ///
    /// - Parameters:
    ///   - title: The title text for the alert
    ///   - message: The message text for the alert
    ///   - actionButtons: The action buttons to display in the alert
    public init(
        title: String,
        message: String,
        actionButtons: [AlertActionButton]
    ) {
        self.title = title
        self.message = message
        self.actionButtons = actionButtons
    }
}

// MARK: - AlertActionButton

/// Represents an action button in an alert.
///
/// Defines button appearance (style) and behavior (action closure). Available styles:
/// primary (emphasized with shortcut), secondary (standard), destructive (warning), cancel (dismisses).
///
/// ```swift
/// AlertActionButton(title: "Confirm", style: .primary) { confirmAction() }
/// AlertActionButton(title: "Delete", style: .destructive) { deleteItem() }
/// AlertActionButton(title: "Cancel", style: .cancel)
/// ```
///
/// - Note: Action closure is optional; buttons without actions simply dismiss the alert
/// - SeeAlso: `AlertItem` for creating complete alert configurations
public struct AlertActionButton: Equatable {
    
    // MARK: - Properties
    
    /// The title text displayed on the button.
    public let title: String
    
    /// The visual style of the button.
    public let style: ButtonStyle
    
    /// The action to perform when the button is tapped.
    ///
    /// If `nil`, tapping the button will only dismiss the alert.
    public let action: (() -> Void)?
    
    // MARK: - Initialization
    
    /// Creates a new alert action button.
    ///
    /// - Parameters:
    ///   - title: The text to display on the button
    ///   - style: The visual style of the button (default: `.secondary`)
    ///   - action: The action to perform when tapped (default: `nil`)
    public init(
        title: String,
        style: ButtonStyle = .secondary,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.style = style
        self.action = action
    }
    
    // MARK: - ButtonStyle
    
    /// Defines the visual appearance and behavior of an alert button.
    public enum ButtonStyle {
        /// Primary action button with emphasis and keyboard shortcut support.
        case primary
        
        /// Standard secondary action button for alternative options.
        case secondary
        
        /// Destructive action button with warning styling for dangerous actions.
        case destructive
        
        /// Cancel button that dismisses the alert without taking action.
        case cancel
    }
    
    // MARK: - Equatable Conformance
    
    /// Compares two alert action buttons for equality based on title and style.
    ///
    /// - Note: Action closures are not compared as they cannot be equated
    public static func == (lhs: AlertActionButton, rhs: AlertActionButton) -> Bool {
        lhs.title == rhs.title && lhs.style == rhs.style
    }
}
