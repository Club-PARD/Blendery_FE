//
//  RecipeTitle.swift
//  Blendery
//
//  Created by 박영언 on 12/26/25.
//

import SwiftUI

struct RecipeTitle: View {
    var body: some View {
        HStack{
            ZStack{
                Circle()
                    .fill(
                        Color(
                        red: 217/255, green: 217/255,
                        blue: 217/255, opacity: 1.0)
                    )
                    .frame(width: 68.17, height: 68.17)
                Image("coffeeExample")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 37.5, height: 55.63)
            }
            
            VStack {
                HStack {
                    OptionBadge()
                    Spacer()
                    FavoriteButton()
                }
                Text("카페모카")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    RecipeTitle()
}
