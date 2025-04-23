//
//  FindOnPageBarView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 17.04.2025.
//

import SwiftUI
import WebKit

struct FindOnPageBarView: View {
    @Environment(\.browser) private var browser
    
    @FocusState private var fieldIsFocused: Bool
    @State private var searchText: String = ""
    var isSearchTextEmpty: Bool {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

//    @State private var currentMatch: Int = 0
//    @State private var matchCount: Int = 0

    let findNextConfig = WKFindConfiguration()
    let findPreviousConfig = WKFindConfiguration()
    
    func findNextWord() {
        guard let currentTab = browser.getCurrentTab() else { return }
        findNextConfig.caseSensitive = false
        findNextConfig.wraps = true

        Task {
            try? await currentTab.webView?.find(searchText, configuration: findNextConfig)
        }
    }
    func findPreviousWord() {
        guard let currentTab = browser.getCurrentTab() else { return }
        findPreviousConfig.caseSensitive = false
        findPreviousConfig.wraps = true
        findPreviousConfig.backwards = true
        
        Task {
            try? await currentTab.webView?.find(searchText, configuration: findPreviousConfig)
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            TextField("Find…", text: $searchText) {
                if let event = NSApplication.shared.currentEvent, event.modifierFlags.contains(.shift) {
                    findPreviousWord()
                } else {
                    findNextWord()
                }
                    
            }
            .textFieldStyle(.plain)
            .focused($fieldIsFocused)
                

            if isSearchTextEmpty == false {
                Button(action: findPreviousWord) {
                    Image(systemName: "arrow.up")
                        .padding(4)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Button(action: findNextWord) {
                    Image(systemName: "arrow.down")
                        .padding(4)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            Button {
                browser.isShowingFindOnCurrentPageUI = false
            } label: {
                Label("Close", systemImage: "xmark")
                    .labelStyle(.iconOnly)
                    .padding(5)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
        }
        .padding(10)
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
        .frame(width: 340)
        .onAppear {
            fieldIsFocused = true
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: browser.isShowingFindOnCurrentPageUI)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}


#Preview {
    @Previewable @State var browser: Browser = Browser()
    FindOnPageBarView()
        .environment(\.browser, browser)
}
