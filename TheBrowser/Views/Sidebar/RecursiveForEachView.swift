//
//  RecursiveForEachView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 14.04.2025.
//

import SwiftUI

/// Recursively displays `SidebarItem`s, handling nesting and drag/drop spacers.
struct RecursiveForEachView: View {
    @Environment(\.browser) private var browser
    let items: [any SidebarItem]
    let parentID: UUID?
    
    // Note: @State for targetedDropIndex here might cause issues if view redraws frequently.
    // Consider managing drop target state more globally if needed, but keep local for now.
    @State private var targetedDropIndex: Int? = nil

    var body: some View {
        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
            // Drop target spacer *before* this item
            DropTargetSpacer(parentID: parentID, index: index, isTargeted: .constant(targetedDropIndex == index)) // Simplified targeting for now
                .frame(height: targetedDropIndex == index ? 20 : 0)

            // Item View (Folder or Tab)
            Group {
                if let folder = item as? Folder {
                    FolderRowView(folder: folder, parentID: parentID)
                } else if let tab = item as? Tab {
                        TabButtonView(tab: tab)
                        .onTapGesture {
                            if browser.selectedTabID != tab.id {
                                browser.selectedTabID = tab.id
                            }
                        }
                        .draggable(SidebarItemTransferable(id: tab.id))
                } else {
                    EmptyView()
                    }
                }
            .padding(.bottom, 2) // Spacing below each item
            
            // Drop target spacer *after the last* item in this list (for appending)
            if index == items.count - 1 {
                DropTargetSpacer(parentID: parentID, index: items.count, isTargeted: .constant(targetedDropIndex == items.count))
                    .frame(height: targetedDropIndex == items.count ? 20 : 0)
            }
        }
    }
} 