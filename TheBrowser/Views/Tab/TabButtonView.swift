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
    
    var title: String {
        guard let currentTab = browser.tabs.first(where: { $0.id == tab.id }) else {
            return "Error"
        }
        
        return currentTab.title
    }
    
    var faviconURL: URL? {
        guard let currentTab = browser.tabs.first(where: { $0.id == tab.id }) else {
            return nil
        }
        
        return currentTab.favicon
    }
    
    var body: some View {
        Button {
            browser.selectedTab = tab.id
            browser.addressBarText = tab.url.host ?? "New Tab"
        } label: {
            HStack {
               FaviconView(url: faviconURL)
                            
                if title == "Loading..." {
                    PageLoadingTabAnimationView()
                        .padding(.leading, 10)
                } else {
                    Text(title)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if isSelected {
                    Button("Close", systemImage: "xmark") {
                        browser.closeTab(tab)
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
            .modifier(TabModifier(isSelected))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var browser: Browser = Browser()
    TabButtonView(tab: .init(url: URL(string: "https://apple.com")!))
        .environment(\.browser, browser)
}
