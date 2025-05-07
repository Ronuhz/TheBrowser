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
                .padding(.horizontal, 10) // Inset for all rows
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

/// Recursively displays `SidebarItem`s, handling nesting and drag/drop spacers.
fileprivate struct RecursiveForEachView: View {
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

/// Displays a single folder row, handling expansion, drag/drop, and context menus.
fileprivate struct FolderRowView: View {
    @Environment(\.browser) private var browser
    @Bindable var folder: Folder
    let parentID: UUID?
    @State private var isHovering: Bool = false
    @State private var isTargetedForDropOnFolder: Bool = false
    @State private var targetedDropIndexInFolder: Int? = nil // For spacers within folder
    
    @State private var showingRenameAlert: Bool = false
    @State private var newName: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Tappable Row Content
            HStack {
                Image(systemName: folder.isExpanded ? "folder" : "folder.fill")
                    .frame(width: 16, height: 16)
                    .foregroundColor(.accentColor)
                Text(folder.name)
                    .lineLimit(1)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(
                Group { // Background based on drop target or hover state
                    if isTargetedForDropOnFolder {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.3))
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(isHovering ? 0.1 : 0.001))
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .contentShape(Rectangle())
            .onHover { isHovering = $0 }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                   browser.toggleFolderExpansion(folderID: folder.id)
                }
            }
            .dropDestination(for: SidebarItemTransferable.self) { items, location in
                guard let firstItem = items.first, firstItem.id != folder.id else { return false }
                browser.moveItem(draggedItemID: firstItem.id, newParentID: folder.id, targetIndex: 0) // Drop into top of folder
                return true
            } isTargeted: { isTargetedForDropOnFolder = $0 }
            .contextMenu { // Context menu for folder actions
                Button("Rename") {
                    newName = folder.name
                    showingRenameAlert = true
                }
                Button("Delete", role: .destructive) {
                    browser.deleteItem(itemID: folder.id)
                }
            }
            .alert("Rename Folder", isPresented: $showingRenameAlert) { // Rename alert
                TextField("Folder Name", text: $newName)
                Button("Rename") { if !newName.isEmpty { browser.renameItem(itemID: folder.id, newName: newName) } }
                Button("Cancel", role: .cancel) { }
            } message: { Text("Enter a new name for the folder \"\(folder.name)\".") }
            
            // Display children if expanded
            if folder.isExpanded {
                // Spacer for dropping at the top of the children list
                 DropTargetSpacer(parentID: folder.id, index: 0, isTargeted: .constant(targetedDropIndexInFolder == 0)) // Simplified targeting
                     .frame(height: targetedDropIndexInFolder == 0 ? 20 : 0)
                
                RecursiveForEachView(items: folder.children, parentID: folder.id)
                    .padding(.leading, 18) // Indent children
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: folder.isExpanded) // Animate expansion
        .draggable(SidebarItemTransferable(id: folder.id))
    }
}

/// An invisible rectangle acting as a drop target between or around sidebar items.
fileprivate struct DropTargetSpacer: View {
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

#Preview {
    @Previewable @State var browser: Browser = Browser()
    SidebarView()
        .environment(\.browser, browser)
}
