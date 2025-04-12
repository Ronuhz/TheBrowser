//
//  TabButtonView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 11.04.2025.
//

import SwiftUI

struct TabButtonView: View {
    let tab: Tab
    
    @Environment(\.browser) private var browser
    
    var isSelected: Bool {
        browser.selectedTab == tab.id
    }
    
    @State private var isHoveringOverTabButton: Bool = false
    
    var body: some View {
        Button {
            browser.selectedTab = tab.id
        } label: {
            HStack {
                FaviconView(for: tab.id)
                            
                PageTabTitleView(for: tab.id)
                
                Spacer()
                
                if isSelected || isHoveringOverTabButton {
                    Button("Close", systemImage: "xmark") {
                        browser.closeTab(tab)
                    }
                    .fontWeight(.bold)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
            .modifier(TabModifier(isSelected, isHoveringOverTabButton))
            .contentShape(Rectangle())
            .onHover { value in
                isHoveringOverTabButton = value
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var browser: Browser = Browser()
    TabButtonView(tab: .init(url: URL(string: "https://www.apple.com/")!))
        .environment(\.browser, browser)
}
