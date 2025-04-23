//
//  SiteSettingsViewQuickButton.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 13.04.2025.
//

import SwiftUI

struct SiteSettingsViewQuickButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    
    init(_ title: String, systemImage: String, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }
    
    var body: some View {
        Button { action() } label: {
            Label(title, systemImage: systemImage)
                .modifier(SiteSettingsViewQuickButtonLabelModifier())
        }
        .modifier(SiteSettingsViewQuickButtonModifier())
    }
}


#Preview {
    SiteSettingsViewQuickButton("Share", systemImage: "square.and.arrow.up") { }
}
