//
//  FaviconView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 11.04.2025.
//

import SwiftUI

struct FaviconView: View {
    let tabID: Tab.ID
    
    init(for tabID: Tab.ID) {
        self.tabID = tabID
    }
    
    @Environment(\.browser) private var browser
    
    var currentTab: Tab? {
        browser.findTabRecursive(id: tabID, in: browser.sidebarItems)
    }
    
    var faviconURL: URL? {
        currentTab?.favicon
    }
    
    var iconFromTab: Image? {
        currentTab?.icon
    }
    
    var body: some View {
        if let icon = iconFromTab {
            icon
                .resizable()
                .frame(width: 16, height: 16)
        } else if let favURL = faviconURL {
            AsyncImage(url: favURL) { image in
                image
                    .resizable()
                    .frame(width: 16, height: 16)
            } placeholder: {
                Image(systemName: "doc.text")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .opacity(0.5)
            }
        } else {
            Image(systemName: "doc.text")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .opacity(0.5)
        }
    }
}

#Preview {
    @Previewable @State var browserPreview: Browser = {
        let browser = Browser()
        if browser.allTabs.isEmpty {
            browser.addTab(url: URL(string: "https://example.com")!, name: "Preview Tab")
        }
        return browser
    }()
    
    let previewTabID: Tab.ID = browserPreview.allTabs.first?.id ?? UUID()

    return FaviconView(for: previewTabID)
        .environment(\.browser, browserPreview)
}
