//
//  GoForwardButtonView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 11.04.2025.
//

import SwiftUI

struct GoForwardButtonView: View {
    @Environment(\.browser) private var browser
    
    @State private var animationTriggerSwitch: Bool = false
    
    var body: some View {
        Button {
            browser.goForwardOnCurrentTab()
            animationTriggerSwitch.toggle()
        } label: {
            Label("Go Back", systemImage: "arrow.right")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .centerFirstTextBaseline)
        }
        .symbolEffect(.wiggle.right, value: animationTriggerSwitch)
        .font(.title3)
    }
}

#Preview {
    @Previewable @State var browser: Browser = Browser()
    GoForwardButtonView()
        .environment(\.browser, browser)
}
