//
//  NewTabButtonView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI

struct NewTabButtonView: View {
    let addTab: () -> Void
    
    var body: some View {
        Button(action: addTab) {
            HStack(spacing: 0) {
                Image(systemName: "plus")
                    .padding(8)
                    .fontWeight(.black)
                Text("New Tab")
            }
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .buttonStyle(.plain)
    }
}

#Preview {
    NewTabButtonView() { }
}
