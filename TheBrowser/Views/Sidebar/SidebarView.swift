//
//  SidebarView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 14.04.2025.
//

import SwiftUI

/// The main view container for the browser sidebar.
struct SidebarView: View {
    @Environment(\.browser) private var browser
    @State private var isRootDropTargeted: Bool = false // Needed for DropTargetSpacer
    @State private var addFolderAnimationTrigger: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Controls
            SearchBarView()
                .padding(.vertical, 8)
            PageLoadingProgressView()
            NewTabButtonView()
                .padding(.bottom, 8)
            
            @Bindable var browser = browser
            
            // Scrollable List of Sidebar Items
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Spacer for dropping at the very top of the root list
                    DropTargetSpacer(parentID: nil, index: 0, isTargeted: $isRootDropTargeted)
                        .frame(height: isRootDropTargeted ? 20 : 8)
                    
                    // Recursive view for displaying items
                    RecursiveForEachView(items: browser.sidebarItems, parentID: nil)
                }
                .frame(maxWidth: .infinity, minHeight: 50) // Ensure drop target area has size
                .dropDestination(for: SidebarItemTransferable.self) { items, location in
                    // Handles dropping into the empty space at the *bottom* of the root list.
                    guard let firstItem = items.first else { return false }
                    browser.moveItem(draggedItemID: firstItem.id, newParentID: nil, targetIndex: browser.sidebarItems.count)
                    return true
                } isTargeted: { targeted in
                    // Visual feedback for the bottom drop area (if needed) could be handled differently,
                    // for now, the spacers provide primary feedback for indexed drops.
                }
            }
            .frame(maxHeight: .infinity) // Allow list to grow
            
            // Bottom Controls
            HStack {
                Button {
                    browser.createFolder(name: "New Folder")
                    addFolderAnimationTrigger.toggle()
                } label: {
                    Label("New Folder", systemImage: "folder.badge.plus")
                        .labelStyle(.iconOnly)
                        .symbolEffect(.bounce.down, value: addFolderAnimationTrigger)
                }
                .buttonStyle(.plain)
                .padding(10)
                
                Spacer()
            }
        }
    }
}

#Preview {
    @Previewable @State var browser: Browser = Browser()
    SidebarView()
        .environment(\.browser, browser)
} 