//
//  SearchSuggestionView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 12.04.2025.
//

import SwiftUI

struct SearchSuggestionView: View {
    let suggestion: String
    
    init(for suggestion: String) {
        self.suggestion = suggestion
    }
    
    @Environment(\.browser) private var browser
    @State private var isHoveringOverSearchSuggestion: Bool = false
    
    var body: some View {
        Button {
            browser.addTab(searchTerm: suggestion)
            browser.isSearchBarOpen = false
        } label: {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: suggestion.urlValue == nil ? "magnifyingglass" : "globe")
                   .font(.title3)
               Text(suggestion)
                   .font(.title2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(.gray.opacity(isHoveringOverSearchSuggestion ? 0.2 : 0))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .onHover { value in
            isHoveringOverSearchSuggestion = value
        }
    }
}
