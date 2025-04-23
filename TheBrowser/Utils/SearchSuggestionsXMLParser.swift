//
//  SearchSuggestionsXMLParser.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 12.04.2025.
//

import Foundation

extension FloatingSearchBarView {
    class SearchSuggestionsXMLParser: NSObject, XMLParserDelegate {
        var suggestions = [String]()
        
//        Called when the parser starts an element
//        If the element is "suggestion", the "data" attribute is extracted and saved
        func parser(_ parser: XMLParser,
                    didStartElement elementName: String,
                    namespaceURI: String?,
                    qualifiedName qName: String?,
                    attributes attributeDict: [String: String] = [:]) {
//            Check for the "suggestion" element and extract its "data" attribute
            if elementName == "suggestion",
               let dataValue = attributeDict["data"] {
                suggestions.append(dataValue)
            }
        }
    }
    
    func parseSearchSuggestionsXMLData(_ xmlData: Data) -> [String] {
        guard let xmlString = String(data: xmlData, encoding: .isoLatin1),
              let utf8Data = xmlString.data(using: .utf8) else {
            print("Error converting XML data encoding")
            return []
        }
        
        let parser = XMLParser(data: utf8Data)
        let searchSuggestionsXMLParser = SearchSuggestionsXMLParser()
        parser.delegate = searchSuggestionsXMLParser
        
//        Parse the XML data.
        if parser.parse() {
            return searchSuggestionsXMLParser.suggestions
        } else {
            if let error = parser.parserError {
                print("Error parsing XML: \(error)")
            }
            return []
        }
    }
}
