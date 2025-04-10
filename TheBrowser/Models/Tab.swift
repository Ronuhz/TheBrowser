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
    var url: URL
    var webView: WKWebView? = WKWebView()
    
    static func == (lhs: Tab, rhs: Tab) -> Bool {
        lhs.id == rhs.id
    }
}
