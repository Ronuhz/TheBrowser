//
//  TabModifier.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI

struct TabModifier: ViewModifier {
    let selected: Bool
    
    init(_ selected: Bool) {
        self.selected = selected
    }
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(.gray.opacity(selected ? 0.6 : 0))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
