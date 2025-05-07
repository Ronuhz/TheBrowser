import SwiftUI

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