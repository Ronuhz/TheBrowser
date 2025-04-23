//
//  SiteSettingsView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 12.04.2025.
//

import UniformTypeIdentifiers
import SwiftUI
import WebKit
import Security
import SecurityInterface

struct SiteSettingsView: View {
    @Environment(\.browser) private var browser
    
    @State private var isDarkThemeEnabled: Bool = false
    var lightsOffTitle: String {
        "Lights \(isDarkThemeEnabled ? "Off" : "On")"
    }
    var lightOffImage: String {
        isDarkThemeEnabled ? "lightbulb" : "lightbulb.slash"
    }
    
    var currentURL: URL? {
        guard let currentTab = browser.getCurrentTab() else { return nil }
        return currentTab.url
    }
    
    var isSecure: Bool {
        guard let currentTab = browser.getCurrentTab() else { return false }
        return currentTab.webView?.hasOnlySecureContent ?? false
    }

    var body: some View {
        VStack {
            HStack(spacing: 9) {
                if let currentURL {
                    ShareLink(item: currentURL) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .modifier(SiteSettingsViewQuickButtonLabelModifier())
                    }
                    .modifier(SiteSettingsViewQuickButtonModifier())
                }
                
                SiteSettingsViewQuickButton(lightsOffTitle, systemImage: lightOffImage) {
                    guard let currentTab = browser.getCurrentTab() else { return }
                    currentTab.webView?.underPageBackgroundColor = isDarkThemeEnabled ? .black : .clear
                    currentTab.webView?.evaluateJavaScript("""
                        var odmcss = `
                        :root {
                            filter: invert(90%) hue-rotate(180deg) brightness(100%) contrast(100%);
                            background: #fff;
                        } 

                        iframe, img, image, video, [style*="background-image"] { 
                            filter: invert() hue-rotate(180deg) brightness(105%) contrast(105%);
                        } 
                        `;
                          
                        id = "the-browser-dark-theme";
                        element = document.getElementById(id);

                        if (null != element) {
                          element.parentNode.removeChild(element);
                        } else {
                          style = document.createElement('style');
                          style.type = "text/css";
                          style.id = id;

                          if (style.styleSheet) {
                            style.styleSheet.cssText = odmcss;
                          } else {
                            style.appendChild(document.createTextNode(odmcss));
                          }

                          document.head.appendChild(style);
                        }
                        """)
                    
                    withAnimation {
                        isDarkThemeEnabled.toggle()
                    }
                }
                
                SiteSettingsViewQuickButton("Find on Page", systemImage: "magnifyingglass") { }
                
                SiteSettingsViewQuickButton("Capture Page", systemImage: "viewfinder.rectangular") {
                    guard let currentTab = browser.getCurrentTab() else { return }
                    
                    let config = WKSnapshotConfiguration()

                    currentTab.webView?.takeSnapshot(with: config) { image, error in
                        if let image, let url = snapshotSavePanel(for: .png), let representation = image.tiffRepresentation {
                            let imageRepresentation = NSBitmapImageRep(data: representation)
                            
                            let imageData = imageRepresentation?.representation(using: .png, properties: [:])
                            try? imageData?.write(to: url)
                        }
                    }
                }
            }
            
            Divider()
            
            HStack {
                Button {
                    showCertificatePanel()
                } label: {
                    HStack {
                        Image(systemName: isSecure ? "lock.fill" : "lock.slash.fill")
                        Text(isSecure ? "Secure" : "Insecure")
                    }
                    .font(.title3.bold())
                    .padding(7)
                    .background(.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .foregroundStyle(isSecure ? Color.primary : Color.red)
                }
                .buttonStyle(.plain)
                .disabled(!isSecure)
                
                Spacer()
                
                Menu {
                    Button("Clear Cache") {
                        guard let currentTab = browser.getCurrentTab() else { return }
                        
                        Task { await currentTab.webView?.clearCache() }
                        
                    }
                    Button("Clear Cookies") {
                        guard let currentTab = browser.getCurrentTab() else { return }
                        
                        currentTab.webView?.clearCookies()
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .padding(14)
                        .background(.secondary.opacity(0.1))
                        .clipShape(Circle())
                }
                .menuStyle(.button)
                .buttonStyle(.plain)
                .padding(-4)
                .padding(.trailing, -2)
            }
        }
        .padding(9)
    }
    
    private func snapshotSavePanel(for type: UTType) -> URL? {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [type]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.titleVisibility = .hidden
        savePanel.titlebarSeparatorStyle = .none
        savePanel.titlebarAppearsTransparent = true
        savePanel.nameFieldLabel = "Save As: "
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        savePanel.nameFieldStringValue = "Capture-\(formatter.string(from: Date()))"

        return savePanel.runModal() == .OK ? savePanel.url : nil
    }
    
    private func showCertificatePanel() {
        guard let currentTab = browser.getCurrentTab(), let webView = currentTab.webView else { return }
        guard let serverTrust = webView.serverTrust else {
            print("No certificate trust information available.")
            return
        }
        
        let trustPanel = SFCertificateTrustPanel()
        if let window = NSApplication.shared.keyWindow {
            trustPanel.beginSheet(for: window, modalDelegate: nil, didEnd: nil, contextInfo: nil, trust: serverTrust, showGroup: true)
        } else {
            trustPanel.runModal(for: serverTrust, showGroup: true)
        }
    }
}


#Preview {
    SiteSettingsView()
}
