//
//  FaviconView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 11.04.2025.
//

import SwiftUI

struct FaviconView: View {
    let faviconURL: URL?
    
    init(url faviconURL: URL?) {
        self.faviconURL = faviconURL
    }
    
    var body: some View {
        if let faviconURL {
            AsyncImage(url: faviconURL) { image in
                image
                    .resizable()
                    .frame(width: 16, height: 16)
            } placeholder: {
                RoundedRectangle(cornerRadius: 2)
                    .fill(.secondary.opacity(0.2))
                    .frame(width: 16, height: 16)
            }
        } else {
            RoundedRectangle(cornerRadius: 2)
                .fill(.secondary.opacity(0.2))
                .frame(width: 16, height: 16)
        }
    }
}

#Preview {
    FaviconView(url: .init(string: "https://apple.com/favicon.ico")!)
}
