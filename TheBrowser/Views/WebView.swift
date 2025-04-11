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

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.processPool = WebView.sharedProcessPool
        config.websiteDataStore = .default()
        config.suppressesIncrementalRendering = false
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.applicationNameForUserAgent = "TheBrowser"
        
        // Create the WKWebView
        let wkWebView = WKWebView(frame: .zero, configuration: config)
        wkWebView.allowsMagnification = true
        wkWebView.allowsBackForwardNavigationGestures = true
//        wkWebView.configuration.preferences.isElementFullscreenEnabled = true
        wkWebView.navigationDelegate = context.coordinator
//        wkWebView.customUserAgent = ""
        
        // Load the request.
        let request = URLRequest(url: tab.url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 20)
        if !tab.hasLoaded {
            wkWebView.load(request)
            DispatchQueue.main.async {
                tab.hasLoaded = true
            }
        }
        
        // Save a reference to the WKWebView so the parent view can control it.
        DispatchQueue.main.async {
            tab.webView = wkWebView
        }
        
        return wkWebView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Check if the URL has changed and reload if needed
        if nsView.url != tab.url && !tab.hasLoaded{
            let request = URLRequest(url: tab.url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 20)
            nsView.load(request)
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
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.tab.isLoading = true
                self.parent.tab.title = "Loading..."
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.tab.isLoading = false
                self.parent.tab.title = webView.title ?? "Loading..."
            }
            
            if let baseURL = webView.url, let host = baseURL.host {
                // Fallback to default favicon, e.g., "https://example.com/favicon.ico"
                let defaultFavicon = URL(string: "https://\(host)/favicon.ico")
                DispatchQueue.main.async {
                    self.parent.tab.favicon = defaultFavicon
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.tab.isLoading = false
                self.parent.tab.title = "Error"
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.tab.isLoading = false
                self.parent.tab.title = "Error"
            }
        }
    }
}
