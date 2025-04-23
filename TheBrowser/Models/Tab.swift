//
//  Tab.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import Foundation
import WebKit

struct Tab: Identifiable, Equatable {
    let id: UUID = UUID()
    
    var favicon: URL? = nil
    var url: URL
    weak var webView: WKWebView?
    
    var hasLoaded: Bool = false
    var isLoading: Bool = false
    
    static func == (lhs: Tab, rhs: Tab) -> Bool {
        lhs.id == rhs.id
    }
    
    init(url: URL) {
        self.url = url
        print("Tab created!")
    }
}
