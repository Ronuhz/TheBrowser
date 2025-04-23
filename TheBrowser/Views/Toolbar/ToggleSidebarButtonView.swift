//
//  ToggleSidebarButtonView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 11.04.2025.
//

import SwiftUI

struct ToggleSidebarButtonView: View {
    @Environment(\.browser) private var browser
        
    var body: some View {
        Button {
            browser.isSidebarOpen.toggle()
        } label: {
            Label(browser.isSidebarOpen ? "Close Sidebar" : "Open Sidebar", systemImage: "sidebar.left")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .centerFirstTextBaseline)
        }
        .font(.title3)
    }
}

#Preview {
    @Previewable @State var browser: Browser = Browser()
    ToggleSidebarButtonView()
        .environment(\.browser, browser)
}
