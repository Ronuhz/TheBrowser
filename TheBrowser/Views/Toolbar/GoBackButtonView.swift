//
//  GoBackButtonView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 11.04.2025.
//

import SwiftUI

struct GoBackButtonView: View {
    @Environment(\.browser) private var browser
    
    @State private var animationTriggerSwitch: Bool = false
    
    var body: some View {
        Button {
            browser.goBackOnCurrentTab()
            animationTriggerSwitch.toggle()
        } label: {
            Label("Go Back", systemImage: "arrow.left")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .centerFirstTextBaseline)
        }
        .symbolEffect(.wiggle.left, value: animationTriggerSwitch)
        .font(.title3)
    }
}

#Preview {
    @Previewable @State var browser: Browser = Browser()
    GoBackButtonView()
        .environment(\.browser, browser)
}
