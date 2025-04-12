//
//  Browser.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI
import Observation

extension EnvironmentValues {
    @Entry var browser: Browser = Browser()
}

@Observable
class Browser {
    var isSidebarOpen: Bool = true
    var isSearchBarOpen: Bool = true
    
//    MARK: - Adress Bar
    var addressBarText: String {
        get {
            guard let currentTab = getCurrentTab(), let url = currentTab.webView?.url else { return "" }
            return url.absoluteString
        }
        
        set (newValue) {
            
        }
    }
    
//    MARK: - Tab Handling
    
//    Open Tabs
    var tabs: [Tab] = []
    
//    Currently active tab
    var selectedTab: Tab.ID = .init()
    
//    MARK: - Tab CRUD
    func addTab() {
        let newTab = Tab(url: URL(string: "https://google.com")!)
        tabs.insert(newTab, at: 0)
        selectedTab = newTab.id
    }
    
    func addTab(searchTerm: String) {
        let encodedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchTerm
        let newTab = Tab(url: URL(string: "https://www.google.com/search?q=\(encodedTerm)")!)
        tabs.insert(newTab, at: 0)
        selectedTab = newTab.id
    }
    
    func addTab(url: URL) {
        let newTab = Tab(url: url)
        tabs.insert(newTab, at: 0)
        selectedTab = newTab.id
    }
    
    func closeTab(_ tab: Tab) {
        tab.webView?.pauseAllMediaPlayback {
            self.tabs.removeAll { $0.id == tab.id }
            if self.selectedTab == tab.id, let first = self.tabs.first {
                self.selectedTab = first.id
            }
        }
    }
    
    func getCurrentTab() -> Tab? {
        if let currentIndex = tabs.firstIndex(where: { $0.id == selectedTab }) {
            let currentTab = tabs[currentIndex]
            
            return currentTab
        } else {
            return nil
        }
    }
    
    func stopLoadingCurrentTab() {
        guard let currentTab = getCurrentTab() else { return }
        currentTab.webView?.stopLoading()
    }
    
//    MARK: - Tab Navigation/Action
    func reloadCurrentTab() {
        guard let currentTab = getCurrentTab() else { return }
        currentTab.webView?.reload()
    }
    
    func goBackOnCurrentTab() {
        guard let currentTab = getCurrentTab() else { return }
        currentTab.webView?.goBack()
    }
    
    func goForwardOnCurrentTab() {
        guard let currentTab = getCurrentTab() else { return }
        currentTab.webView?.goForward()
    }
    
//    MARK: - Init
    init() {
        self.selectedTab = self.tabs.first?.id ?? .init()
    }
}
