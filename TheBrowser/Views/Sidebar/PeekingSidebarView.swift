//
//  PeekingSidebarView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 15.04.2025.
//

import SwiftUI

struct PeekingSidebarView: View {
    @Environment(\.browser) private var browser

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                Rectangle()
                    .fill(.clear)
                    .padding(.top, -38)
                    .frame(maxWidth: 10)
                    .onHover { value in
                        if browser.isSidebarOpen == false {
                            withAnimation(.spring.speed(2)) {
                                browser.isSidebarPeeking = true
                            }
                        }
                    }
                
                if browser.isSidebarPeeking {
                    SidebarView()
                        .modifier(PeekingSidebarViewModifier())
                }
                
                Rectangle()
                    .fill(.clear)
                    .padding(.top, -38)
                    .onHover { value in
                        withAnimation(.spring.speed(2)) {
                            browser.isSidebarPeeking = false
                        }
                    }
                    .allowsHitTesting(browser.isSidebarPeeking)
            }
        }

    }
}

#Preview {
    @Previewable @State var browser: Browser = Browser()
    PeekingSidebarView()
        .environment(\.browser, browser)
}
