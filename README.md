# TheBrowser

A minimal yet powerful macOS web browser built with SwiftUI and WebKit. Featuring tabbed browsing, a sidebar UI, a floating search bar with suggestions, keyboard shortcuts, and elegant transitions — all crafted with native Swift best practices.

---

## ✨ Features

- 🎛️ **Sidebar Navigation** – Expandable/collapsible sidebar with tab list, loading progress bar, and quick actions.
- 🌐 **WebKit-based**
- 🔍 **Floating Search Bar** – Instantly searchable with support for URLs and search terms, plus autocomplete suggestions via Google.
- 🗂️ **Tabbed Browsing** – Seamlessly open and manage multiple tabs with animated transitions and visual previews
- 🗂️ **Nested Folders** – Organize tabs into folders, with unlimited nesting and collapsible groups
- 🖱️ **Drag-and-Drop Sidebar** – Reorder tabs and folders, move items in/out of folders, and nest folders using intuitive drag-and-drop
- ⚡ **Keyboard Shortcuts** – Power-user ready with commands like ⌘T (new tab), ⌘W (close tab), ⌘R (refresh), ⌘S (toggle sidebar).
- 🎨 **Dark Mode Toggle per Tab** – Invert page colors with a single click using JavaScript injection (no browser extensions needed).
- 📦 Built with modern **SwiftUI** and **@Observable** pattern

---

## 🛠️ Requirements

- macOS 15.0+
- Xcode 15+
- Swift 5.9+

---

## 🧩 Shortcuts

| Command                  | Shortcut            |
|--------------------------|---------------------|
| New Tab                  | ⌘T                  |
| Close Tab                | ⌘W                  |
| Close Window             | ⇧⌘W                |
| Refresh Page             | ⌘R                  |
| Toggle Sidebar           | ⌘S                  |

---

## 📁 Sidebar Folders & Drag-and-Drop (feat/folders branch)

This branch introduces a powerful, protocol-based sidebar system:

- **Tabs and Folders**: The sidebar supports both tabs and folders. Folders can contain tabs or other folders, allowing unlimited nesting.
- **Expandable/Collapsible**: Folders can be expanded or collapsed to show or hide their contents.
- **Drag-and-Drop**: Easily reorder tabs and folders, move items between folders, or move them back to the root. Drop targets appear above, between, and inside folders for precise placement.
- **Custom Styling**: The sidebar UI is styled to match modern browsers (like Arc), with smooth selection, hover, and expansion effects.

### Usage
- **To create a folder**: Right-click (or use the context menu) in the sidebar and select "New Folder" (if implemented), or use the provided UI button.
- **To move items**: Drag a tab or folder to reorder, nest, or un-nest it. Drop above, between, or inside folders as needed.
- **To collapse/expand**: Click the folder row to toggle its expansion.

> This feature is available on the `feat/folders` branch. Merge to `main` when ready.
