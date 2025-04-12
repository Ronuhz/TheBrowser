//
//  WebViewModifier.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI

struct WebViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .padding(10)
            .padding(.top, -38) // makes top padding equal to trailing, bottom and leading (18 px)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .shadow(color: .black.opacity(0.4), radius: 5)
    }
}
