//
//  ReloadButton.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 11.04.2025.
//

import SwiftUI

struct ReloadButton: View {
    @Environment(\.browser) private var browser
    
    var icon: String {
        guard let currentTab = browser.getCurrentTab() else { return "xmark" }
        return currentTab.isLoading ? "xmark" : "arrow.clockwise"
    }
    
    var body: some View {
        Button {
            browser.reloadCurrentTab()
        } label: {
            Label("Reload", systemImage: icon)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .centerFirstTextBaseline)
        }
        .contentTransition(.symbolEffect(.replace))
        .font(.title3)
    }
}

#Preview {
    @Previewable @State var browser: Browser = Browser()
    ReloadButton()
        .environment(\.browser, browser)
}
