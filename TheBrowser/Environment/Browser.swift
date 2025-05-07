//
//  Browser.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI
import Observation
import WebKit

extension EnvironmentValues {
    /// Provides access to the shared `Browser` instance in the SwiftUI environment.
    @Entry var browser: Browser = Browser()
}

/// Manages the overall state of the browser window, including sidebar items (tabs and folders),
/// selection, web view interactions, drag and drop operations, and other UI states.
///
/// This class is marked `@Observable` and injected into the SwiftUI environment
/// to be accessible by various views.
@Observable
class Browser {
    // MARK: - State Properties

    /// Controls the visibility of the main sidebar.
    var isSidebarOpen: Bool = true
    /// Indicates if the sidebar is temporarily peeking out.
    var isSidebarPeeking: Bool = false
    /// Controls the visibility of the floating search bar.
    #if DEBUG
    var isSearchBarOpen: Bool = false
    #else
    var isSearchBarOpen: Bool = true
    #endif
    
    /// The hierarchical list of items displayed in the sidebar.
    ///
    /// This array contains objects conforming to ``SidebarItem``, such as ``Tab`` or ``Folder`` instances.
    /// Modifications to this array (or properties of its `@Observable` elements) trigger UI updates.
    var sidebarItems: [any SidebarItem] = []

    /// The `UUID` of the currently selected tab, used to determine which web view is active.
    var selectedTabID: Tab.ID? = nil
    
    /// A computed property providing a flattened list of all ``Tab`` instances within the ``sidebarItems`` hierarchy.
    /// Useful for views that need to iterate over all available web views.
    var allTabs: [Tab] {
        var tabs: [Tab] = []
        func collectTabs(from items: [any SidebarItem]) {
            for item in items {
                if let tab = item as? Tab {
                    tabs.append(tab)
                }
                if let folder = item as? any FolderRepresentable { // Use `any`
                    collectTabs(from: folder.children)
                }
            }
        }
        collectTabs(from: sidebarItems)
        return tabs
    }

    /// Indicates if the notification for copying a URL should be shown.
    var isShowingCurrentTabURLCopiedNotification: Bool = false
    /// Used to uniquely identify the URL copied notification instance for transitions.
    var currentTabURLCopiedNotificationID: UUID = UUID()
    /// Controls the visibility of the "Find on Page" UI bar.
    var isShowingFindOnCurrentPageUI: Bool = false

    // MARK: - Initialization

    /// Initializes the browser state with default example content.
    init() {
        let initialTab = Tab(url: URL(string: "https://google.com")!, name: "Google")
        self.sidebarItems = [initialTab]
        self.selectedTabID = initialTab.id
        
        let workFolder = Folder(name: "Work")
        let tabInWorkFolder = Tab(url: URL(string: "https://www.apple.com")!, name: "Apple")
        workFolder.children.append(tabInWorkFolder)
        self.sidebarItems.append(workFolder)
        
        let personalFolder = Folder(name: "Personal")
        let travelSubFolder = Folder(name: "Travel Plans")
        let parisTab = Tab(url: URL(string: "https://en.wikipedia.org/wiki/Paris")!, name: "Paris Trip")
        
        travelSubFolder.children.append(parisTab)
        personalFolder.children.append(travelSubFolder)
        self.sidebarItems.append(personalFolder)
        
        let anotherTab = Tab(url: URL(string: "https://developer.apple.com/swift/")!, name: "Swift Lang")
        self.sidebarItems.append(anotherTab)
    }
    
    // MARK: - Sidebar Item Management (CRUD)

    /// Adds a new tab to the sidebar, potentially within a specified folder.
    ///
    /// If `folderID` is `nil`, the tab is added to the root level.
    /// The new tab becomes the selected tab.
    ///
    /// - Parameters:
    ///   - url: The `URL` for the new tab.
    ///   - name: An optional initial name for the tab.
    ///   - folderID: The optional `UUID` of a parent folder.
    func addTab(url: URL, name: String? = nil, to folderID: Folder.ID? = nil) {
        let newTab = Tab(url: url, name: name)
        if let folderID = folderID {
            if !recursivelyAddItem(newTab, toFolderID: folderID, in: &sidebarItems) {
                print("Error: Folder with ID \(folderID) not found anywhere. Adding tab to root.")
                sidebarItems.insert(newTab, at: 0) // Insert at top if folder not found
            }
        } else {
            sidebarItems.insert(newTab, at: 0) // Insert new root tabs at the top
        }
        selectedTabID = newTab.id
    }
    
    /// Adds a new tab by performing a web search for the given term.
    /// - Parameters:
    ///   - searchTerm: The term to search for (used as query and initial tab name).
    ///   - folderID: The optional `UUID` of a parent folder.
    func addTab(searchTerm: String, to folderID: Folder.ID? = nil) {
        let encodedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchTerm
        let url = URL(string: "https://www.google.com/search?q=\(encodedTerm)")!
        addTab(url: url, name: searchTerm, to: folderID)
    }

    /// Creates a new, empty folder in the sidebar.
    /// - Parameters:
    ///   - name: The name for the new folder.
    ///   - parentFolderID: The optional `UUID` of a parent folder. If `nil`, adds to the root.
    func createFolder(name: String, parentFolderID: Folder.ID? = nil) {
        let newFolder = Folder(name: name)
        if let parentFolderID = parentFolderID {
            if !recursivelyAddItem(newFolder, toFolderID: parentFolderID, in: &sidebarItems) {
                print("Error: Parent folder with ID \(parentFolderID) not found anywhere. Adding folder to root.")
                sidebarItems.append(newFolder) // Append to end if parent not found
            }
        } else {
            sidebarItems.append(newFolder) // Append new root folders to the end
        }
    }
    
    /// Closes the specified tab, removing it from the sidebar hierarchy.
    ///
    /// If the closed tab was selected, selects the next available tab.
    /// - Parameter tab: The ``Tab`` instance to close.
    func closeTab(_ tab: Tab) {
        let tabIDToClose = tab.id
        if removeItem(withID: tabIDToClose, from: &sidebarItems) != nil {
            if self.selectedTabID == tabIDToClose {
                self.selectedTabID = findFirstTabRecursive(in: sidebarItems)?.id
            }
        } else {
            print("Tab with ID \(tabIDToClose) not found for closing.")
        }
    }

    /// Renames a sidebar item (tab or folder).
    /// - Parameters:
    ///   - itemID: The `UUID` of the item to rename.
    ///   - newName: The new name for the item. Must not be empty after trimming whitespace.
    func renameItem(itemID: UUID, newName: String) {
        guard !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        if !findAndRenameItem(itemID: itemID, newName: newName, in: &sidebarItems) {
             print("Rename Error: Item with ID \(itemID) not found.")
        }
    }
    
    /// Deletes a sidebar item (tab or folder) and its children recursively.
    ///
    /// If the deleted item was the selected tab, selects the next available tab.
    /// - Note: This currently does not prompt for confirmation when deleting non-empty folders.
    /// - Parameter itemID: The `UUID` of the item to delete.
    func deleteItem(itemID: UUID) {
        let _ = removeItem(withID: itemID, from: &sidebarItems)
        if itemID == selectedTabID {
            selectedTabID = findFirstTabRecursive(in: sidebarItems)?.id
        }
    }
    
    // MARK: - Item Access

    /// Retrieves the currently selected ``Tab`` instance based on ``selectedTabID``.
    /// - Returns: The selected ``Tab``, or `nil` if no tab is selected or found.
    func getCurrentTab() -> Tab? {
        guard let selectedTabID = selectedTabID else { return nil }
        return findTabRecursive(id: selectedTabID, in: sidebarItems)
    }

    /// Recursively finds the first available tab within a list of items.
    ///
    /// Used, for example, to select a new tab after the current one is closed.
    /// - Parameter items: The list of ``SidebarItem``s to search within.
    /// - Returns: The first ``Tab`` found, or `nil`.
    func findFirstTabRecursive(in items: [any SidebarItem]) -> Tab? {
        for item in items {
            if let tab = item as? Tab {
                return tab
            }
            if let folder = item as? any FolderRepresentable { // Use any
                if let tabInFolder = findFirstTabRecursive(in: folder.children) {
                    return tabInFolder
                }
            }
        }
            return nil
        }

    /// Recursively finds a ``Tab`` by its `UUID` within a list of items.
    /// - Parameters:
    ///   - id: The `UUID` of the tab to find.
    ///   - items: The list of ``SidebarItem``s to search within.
    /// - Returns: The ``Tab`` with the matching ID, or `nil`.
    func findTabRecursive(id: Tab.ID, in items: [any SidebarItem]) -> Tab? {
        for item in items {
            if let tab = item as? Tab, tab.id == id {
                return tab
            }
            if let folder = item as? any FolderRepresentable { // Use any
                if let tabInFolder = findTabRecursive(id: id, in: folder.children) {
                    return tabInFolder
                }
            }
        }
        return nil
    }
    
    // MARK: - Web View Actions

    /// Stops the loading process in the currently selected tab's web view.
    func stopLoadingCurrentTab() {
        getCurrentTab()?.webView?.stopLoading()
    }
    
    /// Reloads the content of the currently selected tab.
    func reloadCurrentTab() {
        getCurrentTab()?.webView?.reload()
    }
    
    /// Navigates back in the history of the currently selected tab.
    func goBackOnCurrentTab() {
        getCurrentTab()?.webView?.goBack()
    }
    
    /// Navigates forward in the history of the currently selected tab.
    func goForwardOnCurrentTab() {
        getCurrentTab()?.webView?.goForward()
    }
    
    // MARK: - UI Actions

    /// Copies the URL of the current tab to the system pasteboard and shows a notification.
    func copyCurrentTabURLToClipboard() {
        guard let url = getCurrentTab()?.webView?.url else { return }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(url.absoluteString, forType: .string)
        self.isShowingCurrentTabURLCopiedNotification = true
        self.currentTabURLCopiedNotificationID = UUID()
    }
    
    /// Toggles the expansion state (`isExpanded`) of a folder in the sidebar.
    /// - Parameter folderID: The `UUID` of the folder to toggle.
    func toggleFolderExpansion(folderID: UUID) {
        func findAndToggle(items: inout [any SidebarItem]) -> Bool {
            for i in 0..<items.count {
                if let folder = items[i] as? Folder, folder.id == folderID { // Cast to concrete class
                    folder.isExpanded.toggle()
                    return true
                }
                if let parentFolder = items[i] as? Folder { // Cast to concrete class
                    if findAndToggle(items: &parentFolder.children) {
                        return true
                    }
                }
            }
            return false
        }
        _ = findAndToggle(items: &sidebarItems)
    }
    
    // MARK: - Drag and Drop

    /// Moves a sidebar item (tab or folder) to a new location (parent and index) within the hierarchy.
    ///
    /// Called by drop destinations in the sidebar UI.
    /// - Parameters:
    ///   - draggedItemID: The `UUID` of the item being moved.
    ///   - newParentID: The `UUID` of the target folder, or `nil` to move to the root level.
    ///   - targetIndex: The desired insertion index within the new parent's children array.
    func moveItem(draggedItemID: UUID, newParentID: UUID?, targetIndex: Int) {
        if let parentID = newParentID, draggedItemID == parentID {
            print("Error: Cannot drop a folder onto itself.")
            return
        }
        guard let draggedItem = removeItem(withID: draggedItemID, from: &sidebarItems) else {
            print("Drag and Drop: Failed to find/remove dragged item: \(draggedItemID).")
            return
        }
        
        // TODO: Implement robust check to prevent dropping a parent into its own descendant.

        if let parentID = newParentID {
            if !insertItem(draggedItem, intoFolderID: parentID, at: targetIndex, inItems: &sidebarItems) {
                print("Drag and Drop: Failed to find target folder: \(parentID). Re-adding to root.")
                sidebarItems.insert(draggedItem, at: min(targetIndex, sidebarItems.count))
            }
        } else {
            sidebarItems.insert(draggedItem, at: min(targetIndex, sidebarItems.count))
        }
    }

    // MARK: Private Helpers (Drag/Drop, Rename)
    
    /// Removes an item by its ID from a given list of items or its sub-folders recursively.
    /// Returns the removed item if found, otherwise nil.
    private func removeItem(withID itemID: UUID, from items: inout [any SidebarItem]) -> (any SidebarItem)? {
        if let index = items.firstIndex(where: { $0.id == itemID }) {
            return items.remove(at: index)
        }
        for i in 0..<items.count {
            if let folder = items[i] as? Folder { // Use let
                if let removedItem = removeItem(withID: itemID, from: &folder.children) {
                    return removedItem
                }
            }
        }
        return nil
    }

    /// Recursively inserts an item into a specific folder's children at a given index.
    private func insertItem(_ item: any SidebarItem, intoFolderID: UUID, at index: Int, inItems: inout [any SidebarItem]) -> Bool {
        for i in 0..<inItems.count {
            if let folder = inItems[i] as? Folder { // Use let
                if folder.id == intoFolderID {
                    folder.children.insert(item, at: min(index, folder.children.count))
                    return true
                }
                if insertItem(item, intoFolderID: intoFolderID, at: index, inItems: &folder.children) {
                    return true
                }
            }
        }
        return false
    }
    
    /// Recursively adds an item to a specific folder (appends to end), used by `addTab`/`createFolder`.
    private func recursivelyAddItem(_ item: any SidebarItem, toFolderID: UUID, in items: inout [any SidebarItem]) -> Bool {
        for i in 0..<items.count {
            if let folder = items[i] as? Folder { // Use let
                if folder.id == toFolderID {
                    folder.children.append(item)
                    return true
                }
                if recursivelyAddItem(item, toFolderID: toFolderID, in: &folder.children) {
                    return true
                }
            }
        }
        return false
    }
    
    /// Recursively finds and renames an item by its ID.
    private func findAndRenameItem(itemID: UUID, newName: String, in items: inout [any SidebarItem]) -> Bool {
        for i in 0..<items.count {
            let currentItem = items[i]
            if currentItem.id == itemID {
                if let folder = currentItem as? Folder {
                    folder.name = newName
                    return true
                } else if let tab = currentItem as? Tab {
                    tab.name = newName
                    return true
                }
            }
            if let folder = currentItem as? Folder { // Use let for recursion check
                if findAndRenameItem(itemID: itemID, newName: newName, in: &folder.children) {
                    return true
                }
            }
        }
        return false
    }
}
