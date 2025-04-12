//
//  PageLoadingProgressView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 11.04.2025.
//

import SwiftUI

struct PageLoadingProgressView: View {
    @Environment(\.browser) private var browser

    var progress: Double {
        guard let currentTab = browser.getCurrentTab() else { return 0.0 }
        
        return currentTab.webView?.estimatedProgress ?? 0.0
    }
    
    var body: some View {
        ProgressView(value: progress, total: 1)
            .controlSize(.mini)
            .tint(.white)
            .padding(.horizontal, 5)
    }
}

#Preview {
    @Previewable @State var browser: Browser = Browser()
    PageLoadingProgressView()
        .environment(\.browser, browser)
}
