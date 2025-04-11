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
            .padding(.top, -26) // 26 - toolbar used, 38 toolbar empty
            .frame(maxWidth: .infinity)
            .shadow(color: .black.opacity(0.4), radius: 5)
    }
}
