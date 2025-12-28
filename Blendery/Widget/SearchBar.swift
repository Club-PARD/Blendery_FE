//
//  SearchBar.swift
//  Blendery
//
//  Created by 박영언 on 12/28/25.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("", text: $text)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .padding(.leading, 16)

            Spacer()

            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(red: 230/255, green: 70/255, blue: 40/255))
                .padding(.trailing, 16)
        }
        .frame(height: 55.352)
        .background(
            Capsule()
                .stroke(
                    Color(red: 230/255, green: 70/255, blue: 40/255),
                    lineWidth: 2
                )
        )
    }
}
