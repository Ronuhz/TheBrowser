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
    
    @Binding var webView: WKWebView?
    @Binding var url: URL
    

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.processPool = WebView.sharedProcessPool
        config.websiteDataStore = .default()
        config.suppressesIncrementalRendering = false
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.applicationNameForUserAgent = "TheBrowser"
        
        // Create the WKWebView
        let wkWebView = WKWebView(frame: .zero)
        wkWebView.allowsMagnification = true
        wkWebView.allowsBackForwardNavigationGestures = true
        wkWebView.configuration.preferences.isElementFullscreenEnabled = true
        wkWebView.navigationDelegate = context.coordinator
        
        // Load the request.
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 20)
        wkWebView.load(request)
        
        // Save a reference to the WKWebView so the parent view can control it.
        DispatchQueue.main.async {
            self.webView = wkWebView
        }
        
        return wkWebView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Check if the URL has changed and reload if needed
        if nsView.url != url {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 20)
            nsView.load(request)
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
    }
}
