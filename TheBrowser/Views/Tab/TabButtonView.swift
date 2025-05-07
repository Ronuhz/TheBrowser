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
        browser.selectedTabID == tab.id
    }
    
    @State private var isHoveringOverTabButton: Bool = false
    
    var body: some View {
            HStack {
                FaviconView(for: tab.id)
                            
                PageTabTitleView(for: tab.id)
                
                Spacer()
                
                if isSelected || isHoveringOverTabButton {
                Button {
                        browser.closeTab(tab)
                } label: {
                    Label("Close", systemImage: "xmark")
                    .fontWeight(.bold)
                }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                .padding(.trailing, 5)
                }
            }
            .modifier(TabModifier(isSelected, isHoveringOverTabButton))
        .onHover { hovering in
            isHoveringOverTabButton = hovering
        }
    }
}

#Preview {
    @Previewable @State var browserPreview: Browser = {
        let browser = Browser()
        if browser.sidebarItems.first(where: { $0 is Tab }) == nil {
            browser.addTab(url: URL(string: "https://example.com")!, name: "Example Preview")
        }
        return browser
    }()
    
    let previewTab: Tab = browserPreview.allTabs.first ?? Tab(url: URL(string: "https://fallback.com")!)

    return TabButtonView(tab: previewTab)
        .environment(\.browser, browserPreview)
        .padding()
        .frame(width: 200)
}
