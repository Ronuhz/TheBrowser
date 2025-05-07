//
//  WebView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import Observation
import SwiftUI
import WebKit

/// A SwiftUI view that wraps a `WKWebView` to display web content for a given `Tab`.
struct WebView: NSViewRepresentable {
    /// A shared process pool for all web views to potentially share resources.
    static let sharedProcessPool = WKProcessPool()
    
    /// The `Tab` object containing the URL and state for this web view.
    /// Passed as a non-binding let because `Tab` is an `@Observable` class.
    let tab: Tab
    /// Access to the shared browser state.
    @Environment(\.browser) private var browser

    // MARK: - NSViewRepresentable

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.processPool = WebView.sharedProcessPool
        config.websiteDataStore = .default()
        config.suppressesIncrementalRendering = false
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let wkWebView = WKWebView(frame: .zero, configuration: config)
        wkWebView.allowsMagnification = true
        wkWebView.allowsBackForwardNavigationGestures = true
        wkWebView.configuration.preferences.isElementFullscreenEnabled = true
        wkWebView.allowsLinkPreview = true
        wkWebView.navigationDelegate = context.coordinator
        wkWebView.uiDelegate = context.coordinator
        wkWebView.isInspectable = true
        wkWebView.customUserAgent = """
                Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) \
                AppleWebKit/605.1.15 (KHTML, like Gecko) \
                Version/18.4 Safari/605.1.15
                """
        
        // Load initial request if needed
        let request = URLRequest(url: tab.url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        if !tab.hasLoaded {
            wkWebView.load(request)
            tab.hasLoaded = true // Update state on the @Observable Tab object
        }
        
        tab.webView = wkWebView // Assign the web view reference back to the Tab object
        
        return wkWebView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // Hide the web view if its tab is not the selected one.
        webView.isHidden = browser.selectedTabID != tab.id
        
        // Reload if the URL has changed programmatically and hasn't loaded yet
        if let currentWebViewURL = webView.url, currentWebViewURL != tab.url, !tab.hasLoaded {
            let request = URLRequest(url: tab.url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
            webView.load(request)
            tab.hasLoaded = true
        } else if webView.url == nil && !tab.url.absoluteString.isEmpty && !tab.hasLoaded {
            let request = URLRequest(url: tab.url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
            webView.load(request)
                tab.hasLoaded = true
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    /// Acts as the delegate for the `WKWebView`, handling navigation and UI events.
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        // MARK: Delegate Methods
        
        // TODO: Review media capture permissions if needed for specific features.
        // #warning("clean this up") // Removed warning
        func webView(_ webView: WKWebView,
                         requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                         initiatedByFrame frame: WKFrameInfo,
                         type: WKMediaCaptureType,
                         decisionHandler: @escaping (WKPermissionDecision) -> Void) {
                print("Media capture request from \(origin.host) for \(type)")
                // Granting permission by default - review security implications.
                decisionHandler(.grant)
            }
        
        /// Attempts to load the favicon URL for the current page.
        func loadFavicon(_ webView: WKWebView) {
            if let baseURL = webView.url, let host = baseURL.host {
                // Construct a common favicon URL pattern.
                let defaultFavicon = URL(string: "https://\(host)/favicon.ico")
                // Update the parent Tab's favicon URL if different.
                if self.parent.tab.favicon != defaultFavicon {
                        self.parent.tab.favicon = defaultFavicon
                }
            }
        }
        
        /// Updates tab state when navigation starts.
        func startNavigation(_ webView: WKWebView) {
                self.parent.tab.isLoading = true
            loadFavicon(webView) // Attempt to load favicon early
        }
        
        /// Updates tab state when navigation completes (successfully or with failure).
        func navigationCompleted(_ webView: WKWebView) {
                self.parent.tab.isLoading = false
            loadFavicon(webView) // Ensure favicon is loaded/updated
            
            // Update the tab name from the page title if available
            if let pageTitle = webView.title, !pageTitle.isEmpty {
                if self.parent.tab.name != pageTitle {
                    self.parent.tab.name = pageTitle
                }
            }
        }
        
        // MARK: WKNavigationDelegate
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
           startNavigation(webView)
        }
        
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            startNavigation(webView)
            // Load the redirected URL if needed (WKWebView often handles this, but explicit load can be safer)
            if let url = webView.url {
                self.parent.tab.webView?.load(URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60))
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            navigationCompleted(webView)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            navigationCompleted(webView)
            print("Navigation failed: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            navigationCompleted(webView)
             print("Provisional navigation failed: \(error.localizedDescription)")
        }
        
        // MARK: WKUIDelegate
        
        /// Handles requests to open new windows (e.g., links with `target="_blank"`).
        /// Creates a new tab in the browser for the requested URL.
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // If a link would open a new window, open it in a new tab instead.
            if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
                 self.parent.browser.addTab(url: url) // Use the Browser environment object to add a tab
            }
            // Return nil because we are handling the new window creation manually by opening a tab.
            return nil
        }

        // Decide policy for navigation actions (e.g., opening links in new tabs)
        // This was originally used in example, but createWebViewWith is more standard for target=_blank.
        // Keep for reference or other policy decisions if needed.
        /*
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
                if navigationAction.targetFrame == nil {
                    if let url = navigationAction.request.url {
                        self.parent.browser.addTab(url: url)
                    }
                }
                decisionHandler(.allow)
            }
        */
        
        // JavaScript Alerts (alert, confirm, prompt)
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo) async {
            // Implementation using NSAlert...
            await NSAlert.runModalAlert(host: webView.url?.host, message: message)
        }
        
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo) async -> Bool {
             // Implementation using NSAlert...
            await NSAlert.runModalConfirm(host: webView.url?.host, message: message)
        }
        
        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo) async -> String? {
             // Implementation using NSAlert...
            await NSAlert.runModalInput(host: webView.url?.host, prompt: prompt, defaultText: defaultText)
        }
    }
}

// MARK: - NSAlert Helpers (Example)
// Consider moving these helpers to a separate Utility file.
extension NSAlert {
    /// Helper to run a simple modal alert.
    static func runModalAlert(host: String?, message: String) async {
            await withCheckedContinuation { continuation in
                let alert = NSAlert()
            alert.messageText = "\(host ?? "Website") says"
                alert.informativeText = message
                alert.addButton(withTitle: "OK")
                
                if let window = NSApplication.shared.keyWindow {
                alert.beginSheetModal(for: window) { _ in continuation.resume() }
                } else {
                    _ = alert.runModal()
                    continuation.resume()
                }
            }
        }
        
    /// Helper to run a confirmation modal alert.
    static func runModalConfirm(host: String?, message: String) async -> Bool {
            await withCheckedContinuation { continuation in
                    let alert = NSAlert()
                alert.messageText = "\(host ?? "Website") says"
                    alert.informativeText = message
                    alert.addButton(withTitle: "OK")
                    alert.addButton(withTitle: "Cancel")
                    
                    if let window = NSApplication.shared.keyWindow {
                        alert.beginSheetModal(for: window) { response in
                        continuation.resume(returning: response == .alertFirstButtonReturn)
                        }
                    } else {
                        let response = alert.runModal()
                    continuation.resume(returning: response == .alertFirstButtonReturn)
                }
            }
        }
        
    /// Helper to run an input modal alert.
    static func runModalInput(host: String?, prompt: String, defaultText: String?) async -> String? {
            await withCheckedContinuation { continuation in
                let alert = NSAlert()
            alert.messageText = "\(host ?? "Website") says"
                alert.informativeText = prompt
            let inputTextField = NSTextField(string: defaultText ?? "")
                inputTextField.frame = NSRect(x: 0, y: 0, width: 230, height: 24)
                alert.accessoryView = inputTextField
                alert.addButton(withTitle: "OK")
                alert.addButton(withTitle: "Cancel")
                
                if let window = NSApplication.shared.keyWindow {
                    alert.beginSheetModal(for: window) { response in
                    continuation.resume(returning: response == .alertFirstButtonReturn ? inputTextField.stringValue : nil)
                    }
                } else {
                    let response = alert.runModal()
                continuation.resume(returning: response == .alertFirstButtonReturn ? inputTextField.stringValue : nil)
            }
        }
    }
}

//MARK: - WKWebView Extensions
// These should likely move to their own Extensions file.
extension WKWebView {
    /// Clears all cookies from the shared HTTP cookie storage.
    func clearCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
    }
    
    /// Clears website data cache.
    func clearCache() async {
        let records = await WKWebsiteDataStore.default().dataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes())
        _ = await WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records)
        print("Cleared \(records.count) website data records.")
    }
}
