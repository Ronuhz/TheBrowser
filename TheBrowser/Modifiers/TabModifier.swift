//
//  TabModifier.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI

struct TabModifier: ViewModifier {
    let isSelected: Bool
    
    init(_ isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(.gray.opacity(isSelected ? 0.6 : 0))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
