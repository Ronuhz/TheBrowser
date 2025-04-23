//
//  NewTabButtonView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI

struct NewTabButtonView: View {
    @Environment(\.browser) private var browser
    
    @State private var isHoveringOverNewTabButton: Bool = false
    
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
            .padding(.vertical, 3)
            .contentShape(Rectangle())
            .background(.gray.opacity(isHoveringOverNewTabButton ? 0.1 : 0))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onHover { value in
                isHoveringOverNewTabButton = value
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var browser: Browser = Browser()
    NewTabButtonView()
        .environment(\.browser, browser)
}
