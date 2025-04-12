//
//  WebsiteSettingsView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 12.04.2025.
//

import SwiftUI

struct WebsiteSettingsView: View {
    @Environment(\.browser) private var browser
    
    @State private var isDarkThemeEnabled: Bool = false
    var lightsOffTitle: String {
        "Lights \(isDarkThemeEnabled ? "Off" : "On")"
    }
    var lightOffImage: String {
        isDarkThemeEnabled ? "lightbulb" : "lightbulb.slash"
    }

    var body: some View {
        VStack {
            HStack(spacing: 9) {
                SettingsViewQuickButton(lightsOffTitle, systemImage: lightOffImage) {
                    guard let currentTab = browser.getCurrentTab() else { return }
                    currentTab.webView?.underPageBackgroundColor = isDarkThemeEnabled ? .black : .clear
                    currentTab.webView?.evaluateJavaScript("""
                        var odmcss = `
                        :root {
                            filter: invert(90%) hue-rotate(180deg) brightness(100%) contrast(100%);
                            background: #fff;
                        } 

                        iframe, img, image, video, [style*="background-image"] { 
                            filter: invert(180%) hue-rotate(180deg) brightness(105%) contrast(105%);
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
            }
        }
        .padding(9)
    }
}

#Preview {
    WebsiteSettingsView()
}

struct SettingsViewQuickButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    
    init(_ title: String, systemImage: String, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }
    
    var body: some View {
        Button { action() } label: {
            Label(title, systemImage: systemImage)
                .font(.title3)
                .labelStyle(.iconOnly)
                .frame(width: 48, height: 30)
                .background(LinearGradient(colors: [.black.mix(with: .white, by: 0.2), .black.mix(with: .white, by: 0.25)], startPoint: .center, endPoint: .top))
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .buttonStyle(.plain)
        .contentTransition(.symbolEffect(.replace))
    }
}

//#Preview {
//    SettingsViewQuickButtons()
//}
//Button("Lights Out", systemImage: "lightbulb.slash") {
//                   guard let currentTab = browser.getCurrentTab() else { return }
//                   currentTab.webView?.evaluateJavaScript("""
//                       var odmcss = `
//                       :root {
//                           filter: invert(90%) hue-rotate(180deg) brightness(100%) contrast(100%);
//                           background: #fff;
//                       } 
//
//                       iframe, img, image, video, [style*="background-image"] { 
//                           filter: invert(180%) hue-rotate(180deg) brightness(105%) contrast(105%);
//                       } 
//                       `;
//                         
//                       id = "the-browser-dark-theme";
//                       element = document.getElementById(id);
//
//                       if (null != element) {
//                         element.parentNode.removeChild(element);
//                       } else {
//                         style = document.createElement('style');
//                         style.type = "text/css";
//                         style.id = id;
//
//                         if (style.styleSheet) {
//                           style.styleSheet.cssText = odmcss;
//                         } else {
//                           style.appendChild(document.createTextNode(odmcss));
//                         }
//
//                         document.head.appendChild(style);
//                       }
//                       """)
//               }
//                   .padding()
