import SwiftUI

/// Represents a folder in the sidebar capable of containing other `SidebarItem`s (tabs or folders).
protocol FolderRepresentable: SidebarItem {
    /// The ordered collection of items contained directly within this folder.
    var children: [any SidebarItem] { get set }
    /// A Boolean value indicating whether the folder is currently expanded (showing its children) in the sidebar view.
    var isExpanded: Bool { get set }
} 