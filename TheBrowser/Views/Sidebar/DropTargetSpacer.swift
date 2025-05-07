//
//  DropTargetSpacer.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 14.04.2025.
//

import SwiftUI

/// An invisible rectangle acting as a drop target between or around sidebar items.
struct DropTargetSpacer: View {
    @Environment(\.browser) private var browser
    let parentID: UUID?
    let index: Int
    @Binding var isTargeted: Bool

    var body: some View {
        Rectangle()
            .fill(isTargeted ? Color.blue.opacity(0.5) : Color.clear)
            .frame(maxWidth: .infinity)
            .frame(height: isTargeted ? 10 : 4) // Adjust height when targeted vs not
            .dropDestination(for: SidebarItemTransferable.self) { items, location in
                guard let firstItem = items.first else { return false }
                browser.moveItem(draggedItemID: firstItem.id, newParentID: parentID, targetIndex: index)
                return true
            } isTargeted: { targetedState in
                // Avoid rapid flickering by delaying slightly?
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                     withAnimation(.easeInOut(duration: 0.1)) { isTargeted = targetedState }
                }
        }
    }
} 