//
//  PeekingSidebarViewModifier.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 15.04.2025.
//

import SwiftUI

struct PeekingSidebarViewModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(8)
            .padding(.top, 20)
            .background(colorScheme == . dark ? .gray.mix(with: .black, by: 0.5) : .white.mix(with: .gray, by: 0.5))
            .frame(maxWidth: 230, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(radius: 18)
            .padding(.vertical, 10)
            .padding(.top, -38)
            .padding(-4)
            .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading).combined(with: .opacity).animation(.easeOut)))
    }
}
