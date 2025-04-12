//
//  TabModifier.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI

struct TabModifier: ViewModifier {
    let isSelected: Bool
    let isHoveringOverTabButton: Bool
    
    init(_ isSelected: Bool, _ isHoveringOverTabButton: Bool) {
        self.isSelected = isSelected
        self.isHoveringOverTabButton = isHoveringOverTabButton
    }
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(.gray.opacity(isSelected ? 0.6 : isHoveringOverTabButton ? 0.1 : 0))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
