//
//  SidebarContainerModifier.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI

struct SidebarContainerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding([.leading, .vertical])
            .padding(.trailing, -9)
            .padding(.leading, -6)
            .frame(maxWidth: 200, maxHeight: .infinity)
    }
}
