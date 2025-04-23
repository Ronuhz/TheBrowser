//
//  SiteSettingsViewQuickButtonLabelModifier.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 15.04.2025.
//

import SwiftUI

struct SiteSettingsViewQuickButtonLabelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.white)
            .font(.title3)
            .labelStyle(.iconOnly)
            .frame(width: 48, height: 30)
            .background(LinearGradient(colors: [.black.mix(with: .white, by: 0.2), .black.mix(with: .white, by: 0.25)], startPoint: .center, endPoint: .top))
    }
}
