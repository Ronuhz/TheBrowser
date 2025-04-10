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
    var tabs: [Tab] = [
        Tab(url: URL(string: "https://apple.com")!),
        Tab(url: URL(string: "https://duckduckgo.com")!),
        Tab(url: URL(string: "https://youtube.com")!)
    ]
    
    var selectedTab: Tab.ID = .init()
}
