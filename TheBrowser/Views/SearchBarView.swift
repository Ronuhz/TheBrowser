//
//  SearchBarView.swift
//  TheBrowser
//
//  Created by Hunor Zoltáni on 10.04.2025.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var addressBarText: String
//    let goTo: (String) -> Void
    
    init(url addressBarText: Binding<String>) {
        self._addressBarText = addressBarText
//        self.goTo = goTo
    }
    
    var body: some View {
        TextField("Domain", text: $addressBarText)
            .onSubmit {
//                goTo(addressBarText)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(.gray.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .textFieldStyle(.plain)
    }
}

#Preview {
    SearchBarView(url: .constant("apple.com"))
}
