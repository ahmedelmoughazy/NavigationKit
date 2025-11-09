//
//  AlertModifier.swift
//  NavigationKit
//
//  Created by Ahmed Elmoughazy on 09.11.25.
//  Copyright © 2025 Ahmed Elmoghazy. All rights reserved.
//

import SwiftUI

// MARK: - AlertModifier

/// A view modifier that manages alert presentation within the navigation system.
///
/// Implements modal-safe alert presentation logic with support for alert replacement.
/// When a new alert is set while another is visible, the current alert is dismissed
/// and the new one is presented on the next run loop to prevent state conflicts.
///
/// - Note: Private modifier used internally by the alert(alertItem:) View extension
struct AlertModifier: ViewModifier {
    
    // MARK: - Properties
    
    /// The alert item bound from the router.
    @Binding var alertItem: AlertItem?
    
    // MARK: - Body
    
    func body(content: Content) -> some View {
        content
            .alert(
                presentedItem?.title ?? "",
                isPresented: $isPresented,
                presenting: presentedItem,
                actions: { item in
                    actionButtons(item.actionButtons)
                },
                message: { item in
                    Text(item.message)
                }
            )
            .onChange(of: alertItem) { new in
                handleExternalChange(new)
            }
            .onChange(of: isPresented) { new in
                handlePresentationChange(new)
            }
    }
    
    /// The internal alert item currently being presented.
    @State private var presentedItem: AlertItem? = nil
    
    /// Controls whether the alert is currently visible.
    @State private var isPresented: Bool = false
    
    /// Prevents recursive onChange calls during programmatic state changes.
    @State private var preventOnChange: Bool = false
}

// MARK: - Private Methods

private extension AlertModifier {
    
    /// Handles changes to the alert item binding from the router.
    ///
    /// Manages presentation logic including dismissal, new alerts, and replacements.
    ///
    /// - Parameter new: The new alert item value (may be nil)
    func handleExternalChange(_ new: AlertItem?) {
        guard let new = new else {
            // External set to nil -> dismiss
            dismissCurrentAlert()
            return
        }
        
        if !isPresented {
            // No alert on screen: present immediately
            presentAlert(new)
        } else {
            // Alert is on screen: dismiss then re-present the new item
            replaceAlert(with: new)
        }
    }
    
    /// Handles changes to the alert's presentation state.
    ///
    /// Synchronizes user dismissals back to the router.
    ///
    /// - Parameter isNowPresented: The new presentation state
    func handlePresentationChange(_ isNowPresented: Bool) {
        guard !preventOnChange else { return }
        
        // If dismissed by user, clear the router's alert item
        if !isNowPresented {
            alertItem = nil
        }
    }
    
    /// Presents a new alert.
    ///
    /// - Parameter item: The alert item to present
    func presentAlert(_ item: AlertItem) {
        presentedItem = item
        isPresented = true
    }
    
    /// Dismisses the currently visible alert.
    func dismissCurrentAlert() {
        if isPresented {
            isPresented = false
        }
        presentedItem = nil
    }
    
    /// Replaces the currently visible alert with a new one.
    ///
    /// Dismisses current alert and schedules new one on next run loop for smooth transitions.
    ///
    /// - Parameter newItem: The new alert item to present
    func replaceAlert(with newItem: AlertItem) {
        // Temporarily prevent onChange callbacks to avoid recursion
        preventOnChange = true
        isPresented = false
        preventOnChange = false
        
        // Schedule the new alert presentation on the next run loop
        // This ensures the system properly replaces the alert
        DispatchQueue.main.async {
            presentAlert(newItem)
        }
    }
    
    /// Creates button views for the alert's action buttons with appropriate styling.
    ///
    /// - Parameter actionButtons: The action buttons to render
    /// - Returns: A view containing all the alert buttons
    func actionButtons(_ actionButtons: [AlertActionButton]) -> some View {
        ForEach(actionButtons, id: \.title) { button in
            createButton(for: button)
        }
    }
    
    /// Creates a single button view for an action button.
    ///
    /// - Parameter button: The action button configuration
    /// - Returns: A Button view with appropriate styling
    @ViewBuilder
    func createButton(for button: AlertActionButton) -> some View {
        switch button.style {
        case .primary:
            Button(button.title) {
                button.action?()
            }
            .keyboardShortcut(.defaultAction)
            
        case .secondary:
            Button(button.title) {
                button.action?()
            }
            
        case .destructive:
            Button(button.title, role: .destructive) {
                button.action?()
            }
            
        case .cancel:
            Button(button.title, role: .cancel) {
                button.action?()
            }
        }
    }
}
