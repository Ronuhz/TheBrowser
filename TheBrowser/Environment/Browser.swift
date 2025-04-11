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
//    MARK: - Adress Bar
    var addressBarText: String = ""
    
//    MARK: - Tab Handling
    
//    Open Tabs
    var tabs: [Tab] = [
        Tab(url: URL(string: "https://duckduckgo.com")!),
        Tab(url: URL(string: "https://apple.com")!),
        Tab(url: URL(string: "https://youtube.com")!),
    ]
    
//    Currently active tab
    var selectedTab: Tab.ID = .init()
    
//    MARK: - Tab CRUD
    func addTab() {
        let newTab = Tab(url: URL(string: "https://duckduckgo.com")!)
        tabs.insert(newTab, at: 0)
        selectedTab = newTab.id
        addressBarText = newTab.url.host ?? "New Tab"
    }
    
    func closeTab(_ tab: Tab) {
        tabs.removeAll { $0.id == tab.id }
        if selectedTab == tab.id, let first = tabs.first {
            selectedTab = first.id
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
    
//    MARK: - Tab Navigation
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
    
    #warning("not working separate URL normalization")
    func setCurrentTabAddress(to newAddress: String) {
        guard var currentTab = getCurrentTab() else { return }
        let trimmedAddress = newAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        let fullAddress: String
        if trimmedAddress.hasPrefix("http://") || trimmedAddress.hasPrefix("https://") {
           fullAddress = trimmedAddress
        } else {
           fullAddress = "https://" + trimmedAddress
        }
        
        if let url = URL(string: fullAddress) {
            currentTab.hasLoaded = false
            currentTab.url = url
            
        }
    }
    
    //    MARK: - Init
        init() {
            self.selectedTab = self.tabs.first?.id ?? .init()
        }
}
