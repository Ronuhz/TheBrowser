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
        
        let wkWebView = WKWebView(frame: .zero, configuration: config)
        wkWebView.allowsMagnification = true
        wkWebView.allowsBackForwardNavigationGestures = true
        wkWebView.configuration.preferences.isElementFullscreenEnabled = true
        wkWebView.navigationDelegate = context.coordinator
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
        if webView.url != tab.url && !tab.hasLoaded{
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
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
//        MARK: - Favicon, Title and Navigation Helpers
        func loadFavicon(_ webView: WKWebView) {
            if let baseURL = webView.url, let host = baseURL.host {
                let defaultFavicon = URL(string: "https://\(host)/favicon.ico")
                if self.parent.tab.favicon != defaultFavicon {
                    DispatchQueue.main.async {
                        self.parent.tab.favicon = defaultFavicon
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
    }
}
