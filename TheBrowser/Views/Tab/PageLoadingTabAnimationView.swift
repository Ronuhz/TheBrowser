//
//  PageLoadingTabAnimationView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 11.04.2025.
//

import SwiftUI

struct PageLoadingTabAnimationView: View {
    @State private var offset: CGFloat = 0

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(.secondary.opacity(0.2))
                .frame(width: 10, height: 10)
                .offset(x: offset)
                .animation(Animation.timingCurve(0.2, 0.8, 0.2, 1.0).repeatForever().speed(0.5), value: offset)
            
            Circle()
                .fill(.secondary.opacity(0.2))
                .frame(width: 10, height: 10)
                .offset(x: -offset)
                .animation(Animation.timingCurve(0.2, 0.8, 0.2, 1.0).repeatForever().speed(0.5), value: offset)
        }
        .task {
            offset = offset == 0 ? 20 : 0
        }
    }
}

#Preview {
    PageLoadingTabAnimationView()
        .frame(width: 300, height: 300)
}
