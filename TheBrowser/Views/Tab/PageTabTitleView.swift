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

    var title: String? {
        guard let currentTab = browser.tabs.first(where: { $0.id == tabID }) else { return nil }
        return currentTab.webView?.title
    }
    
    var body: some View {
        if let title, title.isEmpty == false {
            Text(title)
                .lineLimit(1)
        } else {
            PageLoadingTabAnimationView()
                .padding(.leading, 10)
        }
    }
}

#Preview {
    @Previewable @State var browser: Browser = Browser()
    PageTabTitleView(for: .init())
        .environment(\.browser, browser)
}
