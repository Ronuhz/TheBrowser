import Foundation
import WebKit

/// Represents a tab that displays web content and appears in the sidebar.
protocol TabRepresentable: SidebarItem {
    /// The URL currently associated with or loaded in the tab.
    var url: URL { get set }
    /// The URL of the tab's favicon, if one has been detected or loaded.
    var favicon: URL? { get set }
    /// A Boolean value indicating whether the tab's web view is currently loading content.
    var isLoading: Bool { get set }
    /// A Boolean value indicating whether the tab has successfully loaded its initial content at least once.
    var hasLoaded: Bool { get set }
    /// A weak reference to the underlying `WKWebView` managing the tab's web content.
    ///
    /// This reference is `weak` to prevent retain cycles.
    var webView: WKWebView? { get }
} 