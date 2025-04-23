//
//  SiteSettingsViewQuickButtonModifier.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 15.04.2025.
//

import SwiftUI

struct SiteSettingsViewQuickButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .buttonStyle(.plain)
            .contentTransition(.symbolEffect(.replace))
    }
}
