//
//  ContentView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @State private var addressBarText: String = "🔍 Search or Enter URL..."
    @State private var url: URL = URL(string: "https://duckduckgo.com")!
    @State private var isShowingSidebar: Bool = true
    
    @State private var tabs: [Tab] = [
        Tab(url: URL(string: "https://apple.com")!),
        Tab(url: URL(string: "https://duckduckgo.com")!),
        Tab(url: URL(string: "https://youtube.com")!)
    ]
    
    @State private var selectedTab: Tab.ID = Tab(url: URL(string: "https://duckduckgo.com")!).id
    
    init() {
        if !tabs.isEmpty {
            self._selectedTab = .init(initialValue: tabs.first!.id)
        }
    }
    
    var body: some View {
        ZStack {
            HStack {
//                Sidebar
                if isShowingSidebar {
                    VStack {
                        SearchBarView(url: $addressBarText)
                            .disabled(true)

                        Divider()
                            .padding(.vertical)
                        
                        NewTabButtonView(addTab: addTab)
                        
                        ForEach(tabs) { tab in
                            let isSelected = selectedTab == tab.id
                            
                            Button {
                                selectedTab = tab.id
                                addressBarText = tab.url.host ?? "New Tab"
                            } label: {
                                HStack {
                                    Text(tab.url.host ?? "New Tab")
                                    Spacer()
                                    if isSelected {
                                        Button("×") {
                                            closeTab(tab)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .modifier(TabModifier(isSelected))
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                    }
                    .modifier(SidebarContainerModifier())
                }
                
                if let currentIndex = tabs.firstIndex(where: { $0.id == selectedTab }) {
                    WebView(webView: $tabs[currentIndex].webView, url: $tabs[currentIndex].url)
                        .modifier(WebViewModifier())
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.regularMaterial)
                        .modifier(WebViewModifier())
                }
            }
        }
        .toolbar {
//            Button("Toggle", systemImage: "sidebar.left") {
//                withAnimation {
//                    isShowingSidebar.toggle()
//                }
//            }
            
            Button("Back", systemImage: "arrow.left") {
                if let currentIndex = tabs.firstIndex(where: { $0.id == selectedTab }), let webView = tabs[currentIndex].webView {
                    if webView.canGoBack {
                        webView.goBack()
                    }
                }
            }
            
            Button("Forward", systemImage: "arrow.right") {
                if let currentIndex = tabs.firstIndex(where: { $0.id == selectedTab }), let webView = tabs[currentIndex].webView {
                    if webView.canGoForward {
                        webView.goForward()
                    }
                }
            }
            
            Button("Reload", systemImage: "arrow.clockwise") {
                if let currentIndex = tabs.firstIndex(where: { $0.id == selectedTab }) {
                    tabs[currentIndex].webView?.reload()
                    print("\(tabs[currentIndex].url.host ?? "Tab") refreshed")
                }
            }
        }
    }
    
    private func addTab() {
        let newTab = Tab(url: URL(string: "https://duckduckgo.com")!)
        tabs.insert(newTab, at: 0)
        selectedTab = newTab.id
        addressBarText = newTab.url.host ?? "New Tab"
    }
    
    private func closeTab(_ tab: Tab) {
        tabs.removeAll { $0.id == tab.id }
        if selectedTab == tab.id, let first = tabs.first {
            selectedTab = first.id
        }
    }
}

#Preview {
    ContentView()
}
