//
//  WebView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import Observation
import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    static let sharedProcessPool = WKProcessPool()
    
    @Binding var tab: Tab
    @Environment(\.browser) private var browser

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
        
        let request = URLRequest(url: tab.url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        if !tab.hasLoaded {
            wkWebView.load(request)
            DispatchQueue.main.async {
                tab.hasLoaded = true
            }
        }
        
        DispatchQueue.main.async {
            tab.webView = wkWebView
        }
        
        return wkWebView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.isHidden = browser.selectedTab != tab.id
        // Check if the URL has changed and reload if needed
        if webView.url != tab.url && !tab.hasLoaded {
            let request = URLRequest(url: tab.url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
            webView.load(request)
            DispatchQueue.main.async {
                tab.hasLoaded = true
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        #warning("clean this up")
        func webView(_ webView: WKWebView,
                         requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                         initiatedByFrame frame: WKFrameInfo,
                         type: WKMediaCaptureType,
                         decisionHandler: @escaping (WKPermissionDecision) -> Void) {

                print("Media capture request from \(origin.host) for \(type)")
                decisionHandler(.grant)
            }
        
        //        MARK: - Favicon, Title and Navigation Helpers
        func loadFavicon(_ webView: WKWebView) {
            if let baseURL = webView.url, let host = baseURL.host {
                // handles cases when the favicon does not exist at normal URL
                webView.evaluateJavaScript(
                    "document.querySelector(\"link[rel~='icon']\")?.href"
                ) { result, error in
                    if let value = result as? String {
                        DispatchQueue.main.async {
                            self.parent.tab.favicon = URL(string: value)
                        }
                    } else {
                        let defaultFavicon = URL(
                            string: "https://\(host)/favicon.ico")
                        if self.parent.tab.favicon != defaultFavicon {
                            DispatchQueue.main.async {
                                self.parent.tab.favicon = defaultFavicon
                            }
                        }
                    }
                }
            }
        }
        func startNavigation(_ webView: WKWebView) {
            DispatchQueue.main.async {
                self.parent.tab.isLoading = true
            }
            
            loadFavicon(webView)
        }
        func navigationCompleted(_ webView: WKWebView) {
            DispatchQueue.main.async {
                self.parent.tab.isLoading = false
            }
            
            loadFavicon(webView)
        }
        
//        MARK: - NAVIGATION
//        MARK: - Early Navigation Starts
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
           startNavigation(webView)
        }
        
//        MARK: - Early Navigation Redirect
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            startNavigation(webView)
            if let url = webView.url {
                self.parent.tab.webView?.load(URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60))
            }
        }
        
//        MARK: - Successful Navigation
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            navigationCompleted(webView)
        }
        
//        MARK: - Failed Navigation
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            navigationCompleted(webView)
        }
        
//        MARK: - Early Navigation failed
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            navigationCompleted(webView)
        }
        
//        MARK: - Open link in New Tab
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
                if navigationAction.targetFrame == nil {
                    if let url = navigationAction.request.url {
                        self.parent.browser.addTab(url: url)
                    }
                }
                decisionHandler(.allow)
            }
        
//        MARK: - JAVASCRIPT ALERTS
//        MARK: - alert("Hello, World!");
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo) async {
            await withCheckedContinuation { continuation in
                let alert = NSAlert()
                alert.messageText = "\(webView.url?.host ?? "Website") says"
                alert.informativeText = message
                alert.addButton(withTitle: "OK")
                
                if let window = NSApplication.shared.keyWindow {
                    alert.beginSheetModal(for: window) { _ in
                        continuation.resume()
                    }
                } else {
                    _ = alert.runModal()
                    continuation.resume()
                }
            }
        }
        
//        MARK: - confirm("Press a button!");
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo) async -> Bool {
            await withCheckedContinuation { continuation in
                    let alert = NSAlert()
                    alert.messageText = "\(webView.url?.host ?? "Website") says"
                    alert.informativeText = message
                    alert.addButton(withTitle: "OK")
                    alert.addButton(withTitle: "Cancel")
                    
                    if let window = NSApplication.shared.keyWindow {
                        alert.beginSheetModal(for: window) { response in
                            let confirmed = (response == .alertFirstButtonReturn)
                            continuation.resume(returning: confirmed)
                        }
                    } else {
                        let response = alert.runModal()
                        let confirmed = (response == .alertFirstButtonReturn)
                        continuation.resume(returning: confirmed)
                    }
                }
            
            
        }
        
//        MARK: - prompt("Please enter your name:", "Hunor");
        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo) async -> String? {
            await withCheckedContinuation { continuation in
                let alert = NSAlert()
                alert.messageText = "\(webView.url?.host ?? "Website") says"
                alert.informativeText = prompt
                
                let inputTextField = NSTextField(string: "")
                inputTextField.stringValue = defaultText ?? ""
                inputTextField.frame = NSRect(x: 0, y: 0, width: 230, height: 24)
                alert.accessoryView = inputTextField
                
                alert.addButton(withTitle: "OK")
                alert.addButton(withTitle: "Cancel")
                
                if let window = NSApplication.shared.keyWindow {
                    alert.beginSheetModal(for: window) { response in
                        if response == .alertFirstButtonReturn {
                            continuation.resume(returning: inputTextField.stringValue)
                        } else {
                            continuation.resume(returning: nil)
                        }
                    }
                } else {
                    let response = alert.runModal()
                    if response == .alertFirstButtonReturn {
                        continuation.resume(returning: inputTextField.stringValue)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }
}

//MARK: - WKWebView Extensions
extension WKWebView {
//    MARK: - Clear All Cookies
    func clearCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
    }
    
//    MARK: - Clear All Cache
    func clearCache() async {
        let records = await WKWebsiteDataStore.default().dataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes())
        for record in records {
            await WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [record])
            print("Removed data record for \(record.displayName)")
        }
    }
}
