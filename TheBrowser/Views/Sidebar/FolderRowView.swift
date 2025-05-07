//
//  FolderRowView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 14.04.2025.
//

import SwiftUI

/// Displays a single folder row, handling expansion, drag/drop, and context menus.
struct FolderRowView: View {
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