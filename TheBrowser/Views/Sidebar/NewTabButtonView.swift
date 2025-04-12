//
//  NewTabButtonView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI

struct NewTabButtonView: View {
    @Environment(\.browser) private var browser
    
    var body:    some View {
        Button {
            browser.isSearchBarOpen = true
        } label: {
            HStack(spacing: 0) {
                Image(systemName: "plus")
                    .padding(8)
                    .fontWeight(.black)
                Text("New Tab")
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var browser: Browser = Browser()
    NewTabButtonView()
        .environment(\.browser, browser)
}
