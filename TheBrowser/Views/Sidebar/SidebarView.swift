//
//  SidebarView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 14.04.2025.
//

import SwiftUI

struct SidebarView: View {
    @Environment(\.browser) private var browser
    
    var body: some View {
        VStack {
            SearchBarView()

            PageLoadingProgressView()
            
            NewTabButtonView()
            
            ScrollView {
                VStack {
                    ForEach(browser.tabs) { tab in
                        TabButtonView(tab: tab)
                    }
                }
                .padding(.horizontal, 10)
            }
            .padding(.horizontal, -10)
        }
    }
}

#Preview {
    @Previewable @State var browser: Browser = Browser()
    SidebarView()
        .environment(\.browser, browser)
}
