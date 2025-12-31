//
//  DetailRecipeView.swift
//  Blendery
//
//  Created by 박영언 on 12/26/25.
//

import SwiftUI

struct DetailRecipeView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack{
            RecipeTitle()
                .padding(22)
            RecipeStepList()
                .padding(16)
            HStack{
                Spacer()
                OptionButton()
                    .padding(.trailing)
            }
            SearchBar(text: $searchText)
                .padding(.horizontal, 16)
                .padding(.vertical, )
        }
    }
}

#Preview {
    DetailRecipeView()
}
