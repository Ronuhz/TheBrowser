//
//  FloatingSearchBarView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 12.04.2025.
//

import SwiftUI

struct FloatingSearchBarView: View {
    @Environment(\.browser) private var browser
    
    @State private var addressBarText: String = ""
    @FocusState private var isFocused: Bool
    @State private var searchSuggestions: [String] = []
    
    var body: some View {
        @Bindable var browser = browser
        
        ZStack {
            if browser.isSearchBarOpen {
//                MARK: - Backdrop
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        browser.isSearchBarOpen = false
                    }
                
                GeometryReader { proxy in
                    VStack {
//                        MARK: Search Bar
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: addressBarText.urlValue == nil ? "magnifyingglass" : "globe")
                                .font(.title3)
                            TextField("Search or Enter URL...", text: $addressBarText)
                                .focused($isFocused)
                                .font(.title2)
                                .fontWeight(.bold)
                                .textFieldStyle(.plain)
                                .onSubmit {
                                    if let url = addressBarText.urlValue {
                                        browser.addTab(url: url)
                                    } else {
                                        browser.addTab(searchTerm: addressBarText)
                                    }
                                    
                                    browser.isSearchBarOpen = false
                                }
                                .onAppear {
                                    isFocused = true
                                }
                        }
                        .padding(12)
                        .frame(maxHeight: 60, alignment: .center)
                        .task(id: addressBarText) {
                            if addressBarText.isEmpty == false {
                                await fetchSuggestions()
                            } else {
                                await MainActor.run {
                                    searchSuggestions = []
                                }
                            }
                        }
                        
//                        MARK: - Search Suggestions
                        if !searchSuggestions.isEmpty {
                            Divider()
                                .padding(.vertical, -11) // fixes padding so it's equal
                            
                            VStack {
                                ForEach(searchSuggestions, id: \.self) { suggestion in
                                    SearchSuggestionView(for: suggestion)
                                }
                            }
                            .padding(.bottom, 12)
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(maxWidth: 700)
                    .background(.ultraThickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.secondary, lineWidth: 0.5)
                    }
                    .shadow(radius: 18)
                    .offset(x: (proxy.size.width - 700) / 2, y: proxy.size.height * 0.3)
                    .animation(.spring.speed(1.5), value: searchSuggestions != [])
                    .onDisappear {
                        searchSuggestions = []
                        addressBarText = ""
                    }
                }
            }
        }
    }
    
    private class SuggestionsCache {
        static let shared = SuggestionsCache()
        private let cache = NSCache<NSString, NSArray>()
        
        func suggestions(for query: String) -> [String]? {
            cache.object(forKey: query as NSString) as? [String]
        }
        
        func setSuggestions(_ suggestions: [String], for query: String) {
            cache.setObject(suggestions as NSArray, forKey: query as NSString)
        }
    }

    private func fetchSuggestions() async {
        if let cached = SuggestionsCache.shared.suggestions(for: addressBarText) {
            await MainActor.run {
                searchSuggestions = cached
            }
            return
        }
        
        let encodedAddressBarText = addressBarText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? addressBarText
        guard let url = URL(string: "https://suggestqueries.google.com/complete/search?output=toolbar&hl=en&q=\(encodedAddressBarText)") else { return }
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return }
        let parsedData = parseSearchSuggestionsXMLData(data)
        let suggestions = Array(parsedData.prefix(5))
        
        SuggestionsCache.shared.setSuggestions(suggestions, for: addressBarText)
        
        await MainActor.run {
            searchSuggestions = suggestions
        }
    }
}
