//
//  Tab.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import Foundation
import WebKit
import SwiftUI
import Observation

/// An observable object representing a browser tab, holding its state and associated web view.
///
/// Tabs conform to ``TabRepresentable`` for use in the sidebar UI.
@Observable
class Tab: Identifiable, Equatable, Hashable, TabRepresentable {
    /// The unique identifier for the tab.
    let id: UUID
    
    /// The display name of the tab.
    ///
    /// This may be derived from the URL, the web page title (`webView.title`), or set manually (e.g., via rename).
    var name: String
    
    /// An optional display icon for the tab.
    ///
    /// This is typically derived from the site's favicon.
    var icon: Image?
    
    /// The current URL loaded or intended to be loaded in the tab.
    var url: URL
    
    /// The URL of the site's favicon, if detected.
    ///
    /// This is typically set by the ``WebView/Coordinator``.
    var favicon: URL?
    
    /// A weak reference to the `WKWebView` instance managing this tab's content.
    weak var webView: WKWebView?
    
    /// Indicates if the initial URL request has been successfully loaded at least once.
    var hasLoaded: Bool
    
    /// Indicates if the web view is currently in the process of loading content.
    var isLoading: Bool
    
    // MARK: - Conformance
    
    static func == (lhs: Tab, rhs: Tab) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /// Creates a new browser tab instance.
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a new `UUID`.
    ///   - url: The initial URL to load in the tab.
    ///   - name: An optional initial name for the tab. If `nil`, defaults to the URL's host or "New Tab".
    ///   - icon: An optional initial display icon. Defaults to `nil`.
    ///   - webView: An optional weak reference to an existing `WKWebView`.
    ///   - hasLoaded: The initial load state. Defaults to `false`.
    ///   - isLoading: The initial loading state. Defaults to `false`.
    init(id: UUID = UUID(), url: URL, name: String? = nil, icon: Image? = nil, webView: WKWebView? = nil, hasLoaded: Bool = false, isLoading: Bool = false) {
        self.id = id
        self.url = url
        self.name = name ?? url.host ?? "New Tab"
        self.icon = icon
        self.webView = webView
        self.hasLoaded = hasLoaded
        self.isLoading = isLoading
        // print("Tab class instance created with URL: \(url) and Name: \(self.name)!")
    }
}
