import SwiftUI
import WebKit // For WKWebView in TabRepresentable

/// A type that can be displayed as an item in the sidebar.
///
/// Conform to this protocol to represent items like tabs or folders within the browser's sidebar UI.
protocol SidebarItem: Identifiable, Hashable, ObservableObject {
    /// A unique, stable identifier for the item.
    var id: UUID { get }
    /// The display name of the item shown in the sidebar.
    var name: String { get set }
    /// An optional icon representing the item (e.g., a favicon or folder icon).
    var icon: Image? { get }
}

/// Represents a tab that displays web content and appears in the sidebar.
protocol TabRepresentable: SidebarItem {
    /// The URL currently associated with or loaded in the tab.
    var url: URL { get set }
    /// The URL of the tab's favicon, if one has been detected or loaded.
    var favicon: URL? { get set }
    /// A Boolean value indicating whether the tab's web view is currently loading content.
    var isLoading: Bool { get set }
    /// A Boolean value indicating whether the tab has successfully loaded its initial content at least once.
    var hasLoaded: Bool { get set }
    /// A weak reference to the underlying `WKWebView` managing the tab's web content.
    ///
    /// This reference is `weak` to prevent retain cycles.
    var webView: WKWebView? { get }
}

/// Represents a folder in the sidebar capable of containing other `SidebarItem`s (tabs or folders).
protocol FolderRepresentable: SidebarItem {
    /// The ordered collection of items contained directly within this folder.
    var children: [any SidebarItem] { get set }
    /// A Boolean value indicating whether the folder is currently expanded (showing its children) in the sidebar view.
    var isExpanded: Bool { get set }
}

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