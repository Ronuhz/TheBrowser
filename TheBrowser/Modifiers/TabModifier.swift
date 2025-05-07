//
//  TabModifier.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI

/// A view modifier that applies standard styling for a tab row in the sidebar.
///
/// This includes padding, background highlighting for selection/hover, and corner rounding.
struct TabModifier: ViewModifier {
    /// Indicates if the tab associated with the modified view is currently selected.
    let isSelected: Bool
    /// Indicates if the pointer is currently hovering over the modified view.
    let isHoveringOverTabButton: Bool
    
    /// Creates a new tab modifier instance.
    /// - Parameters:
    ///   - isSelected: Whether the tab is selected.
    ///   - isHoveringOverTabButton: Whether the pointer is hovering over the tab.
    init(_ isSelected: Bool, _ isHoveringOverTabButton: Bool) {
        self.isSelected = isSelected
        self.isHoveringOverTabButton = isHoveringOverTabButton
    }
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color.gray.opacity(isSelected ? 0.6 : isHoveringOverTabButton ? 0.1 : 0))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .contentShape(Rectangle()) // Ensure the whole area is interactive for hover/gestures
    }
}
