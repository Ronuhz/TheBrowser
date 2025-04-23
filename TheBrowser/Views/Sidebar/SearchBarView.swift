//
//  SearchBarView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI

struct SearchBarView: View {
    @Environment(\.browser) private var browser
    @State private var addressBarText: String = ""
    
    @State private var isShowingSiteSettingsPopover: Bool = false
    
    var body: some View {
        @Bindable var browser = browser

        HStack {
            TextField("Search or Enter URL...",text: .constant(""))
                .disabled(true)
            #warning("Disabled until editing is implemented")
            
            if browser.getCurrentTab() != nil {
                Button("Website Settings", systemImage: "switch.2") {
                    isShowingSiteSettingsPopover.toggle()
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .popover(isPresented: $isShowingSiteSettingsPopover, arrowEdge: .bottom) {
                    SiteSettingsView()
                }
            }
        }
        .onSubmit {
            
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(.gray.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .textFieldStyle(.plain)
    }
}

#Preview {
    @Previewable @State var browser: Browser = Browser()
    SearchBarView()
        .environment(\.browser, browser)
}
