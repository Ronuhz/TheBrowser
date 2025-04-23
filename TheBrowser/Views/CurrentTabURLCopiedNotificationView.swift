//
//  CurrentTabURLCopiedNotificationView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 16.04.2025.
//

import SwiftUI

struct CurrentTabURLCopiedNotificationView: View {
    @Binding var isVisible: Bool
    @State private var isExpanded = false
    @State private var viewOpacity: Double = 1.0

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "link")
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 24, height: 24)

            if isExpanded {
                Text("URL copied!")
                    .font(.system(size: 14, weight: .medium))
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, isExpanded ? 12 : 8)
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
        .frame(width: isExpanded ? 140 : 40, alignment: .trailing)
        .opacity(viewOpacity)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isExpanded)
        .animation(.easeOut(duration: 0.2), value: viewOpacity)
        .onAppear {
            // 1. expand immediately
            withAnimation {
                isExpanded = true
            }
            
            // 2. after 1.2s, collapse
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation {
                    isExpanded = false
                }
                
                // 3. after collapse animates (≈0.4s), fade out
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation {
                        viewOpacity = 0
                    }
                    
                    // 4. finally remove from hierarchy
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isVisible = false
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
