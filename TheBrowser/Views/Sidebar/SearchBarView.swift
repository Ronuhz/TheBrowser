//
//  SearchBarView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI

struct SearchBarView: View {
    @Environment(\.browser) private var browser
    @State private var addressBarText: String = ""
    var body: some View {
        TextField("Search or Enter URL...",text: $addressBarText)
        .onSubmit {
            browser.setCurrentTabAddress(to: addressBarText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(.gray.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .textFieldStyle(.plain)
    }
}

#Preview {
    @Previewable @State var browser: Browser = Browser()
    SearchBarView()
        .environment(\.browser, browser)
}
