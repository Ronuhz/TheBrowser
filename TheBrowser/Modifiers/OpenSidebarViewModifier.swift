//
//  OpenSidebarViewModifier.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 15.04.2025.
//

import SwiftUI

struct OpenSidebarViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.trailing, -9)
            .padding(.leading, -6)
            .frame(maxWidth: 200, maxHeight: .infinity)
            .padding(.leading)
            .transition(.move(edge: .leading).combined(with: .opacity))
    }
}
