import SwiftUI

/// An observable object representing a folder in the sidebar, capable of holding other items.
///
/// Folders provide hierarchical organization for tabs within the browser sidebar.
@Observable
class Folder: FolderRepresentable {
    /// The unique identifier for the folder.
    var id: UUID
    /// The name of the folder displayed in the sidebar.
    var name: String
    /// The icon used to represent the folder (e.g., `folder` or `folder.fill`).
    var icon: Image?
    /// The child items (tabs or other folders) contained within this folder.
    var children: [any SidebarItem]
    /// Indicates whether the folder is expanded (showing children) in the sidebar view.
    var isExpanded: Bool

    /// Creates a new folder instance.
    ///
    /// Use this initializer to create folders either at the root level or nested within other folders.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the folder. Defaults to a new `UUID`.
    ///   - name: The name to display for the folder.
    ///   - icon: The display icon. Defaults to a standard folder system image.
    ///   - children: An array of `SidebarItem`s initially contained within the folder. Defaults to an empty array.
    ///   - isExpanded: The initial expansion state in the UI. Defaults to `true` (expanded).
    init(id: UUID = UUID(), name: String, icon: Image? = Image(systemName: "folder"), children: [any SidebarItem] = [], isExpanded: Bool = true) {
        self.id = id
        self.name = name
        self.icon = icon
        self.children = children
        self.isExpanded = isExpanded
    }

    // MARK: - Conformance

    static func == (lhs: Folder, rhs: Folder) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
} 