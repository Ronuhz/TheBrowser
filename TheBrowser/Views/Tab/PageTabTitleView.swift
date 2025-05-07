//
//  PageTabTitleView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 12.04.2025.
//

import SwiftUI

struct PageTabTitleView: View {
    @Environment(\.browser) private var browser
    
    let tabID: Tab.ID
    
    init(for tabID: Tab.ID) {
        self.tabID = tabID
    }

    var currentTab: Tab? {
        browser.findTabRecursive(id: tabID, in: browser.sidebarItems)
    }

    var titleToDisplay: String {
        if let tab = currentTab {
            if !tab.name.isEmpty && tab.name != "New Tab" {
                return tab.name
            } else if let webViewTitle = tab.webView?.title, !webViewTitle.isEmpty {
                return webViewTitle
            }
            return tab.name
        }
        return "Untitled"
    }
    
    var body: some View {
        Text(titleToDisplay)
            .lineLimit(1)
            .contentTransition(.numericText())
            .animation(.default, value: titleToDisplay)
    }
}

#Preview {
    @Previewable @State var browserPreview: Browser = {
        let browser = Browser()
        if browser.allTabs.isEmpty {
            browser.addTab(url: URL(string: "https://example.com")!, name: "Preview Tab Title")
        }
        return browser
    }()
    
    let previewTabID: Tab.ID = browserPreview.allTabs.first?.id ?? UUID()

    return PageTabTitleView(for: previewTabID)
        .environment(\.browser, browserPreview)
}
