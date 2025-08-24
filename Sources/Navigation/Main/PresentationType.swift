//
//  PresentationType.swift
//  Navigation
//
//  Created by Ahmed Elmoughazy on 24.08.25
//  Copyright © 2025 Ahmed Elmoghazy. All rights reserved.
//

import Foundation

// MARK: - Router Extension

extension Router {
    
    // MARK: - PresentationType
    
    /// Defines the different types of modal presentations available in the navigation system.
    ///
    /// The presentation type determines how a view is modally presented over the current
    /// navigation context.
    ///
    /// ## Available Presentation Types
    ///
    /// ### Sheet
    /// A modal presentation that slides up from the bottom of the screen. The sheet can be
    /// dismissed by swiping down or using dismiss actions.
    ///
    /// ### Full Screen Cover
    /// A modal presentation that covers the entire screen, Must be explicitly dismissed
    /// programmatically.
    ///
    /// ## Usage
    /// ```swift
    /// // Present as sheet
    /// router.present(destination, as: .sheet)
    ///
    /// // Present as full screen cover
    /// router.present(destination, as: .fullScreenCover)
    /// ```
    ///
    /// - SeeAlso: `Router.present(_:as:)` for presentation methods
    public enum PresentationType: CaseIterable {
        
        // MARK: - Cases
        
        /// Presents the view as a sheet that slides up from the bottom.
        case sheet
        
        /// Presents the view as a full-screen cover that takes over the entire screen.
        case fullScreenCover
    }
}
