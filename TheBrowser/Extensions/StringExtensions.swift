//
//  StringExtensions.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 12.04.2025.
//

import Foundation

extension String {
//    Returns a valid URL if the string is a likely URL, otherwise returns nil.
    var urlValue: URL? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
//        Consider it not a URL if it's empty, contains spaces or doesn't contain a dot.
        guard !trimmed.isEmpty, !trimmed.contains(" "), trimmed.contains(".") else {
            return nil
        }
        
//        If no scheme is present, prepend "https://".
        var urlString = trimmed
        if !trimmed.lowercased().hasPrefix("http://") && !trimmed.lowercased().hasPrefix("https://") {
            urlString = "https://" + trimmed
        }
        
        return URL(string: urlString)
    }
}
