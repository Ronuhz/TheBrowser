import SwiftUI
import UniformTypeIdentifiers

/// Defines a custom Uniform Type Identifier for sidebar items during drag and drop.
///
/// Make sure this identifier is also declared in the app's Info.plist under `UTExportedTypeDeclarations`
/// and conforms to `public.data` or `public.content`.
extension UTType {
    /// A UTType representing a draggable sidebar item, identified by `me.ronuhz.TheBrowser.sidebarItem`.
    static var sidebarItem: UTType = UTType(exportedAs: "me.ronuhz.TheBrowser.sidebarItem")
}

/// A lightweight wrapper conforming to `Transferable` for dragging sidebar item identifiers (`UUID`).
///
/// This enables SwiftUI's drag and drop system (`.draggable`, `.dropDestination`) to easily
/// handle the transfer of which specific `SidebarItem` is being moved, using its stable `id`.
struct SidebarItemTransferable: Codable, Transferable {
    /// The unique identifier (`UUID`) of the sidebar item being transferred.
    let id: UUID

    /// The transfer representation configuration.
    ///
    /// Specifies that this struct should be encoded/decoded using `CodableRepresentation`
    /// and associated with the custom ``UTType/sidebarItem`` content type.
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .sidebarItem)
    }
} 