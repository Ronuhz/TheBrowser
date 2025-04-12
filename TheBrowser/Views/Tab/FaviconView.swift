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
    
    var faviconURL: URL? {
        guard let currentTab = browser.tabs.first(where: { $0.id == tabID }) else { return nil }
        return currentTab.favicon
    }
    
    var body: some View {
        if let faviconURL {
            AsyncImage(url: faviconURL) { image in
                image
                    .resizable()
                    .frame(width: 16, height: 16)
            } placeholder: {
                RoundedRectangle(cornerRadius: 2)
                    .fill(.secondary.opacity(0.2))
                    .frame(width: 16, height: 16)
            }
        } else {
            RoundedRectangle(cornerRadius: 2)
                .fill(.secondary.opacity(0.2))
                .frame(width: 16, height: 16)
        }
    }
}

#Preview {
    @Previewable @State var browser: Browser = Browser()
    FaviconView(for: .init())
        .environment(\.browser, browser)
}
