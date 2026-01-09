//
//  DetailRecipeViewByID.swift
//  Blendery
//
//  Created by 박성준 on 1/5/26.
//

import SwiftUI

struct DetailRecipeViewByID: View {
    let recipeId: UUID
    let userId: String
    
    @StateObject private var vm = DetailRecipeViewModel()
    
    var body: some View {
        Group {
            if let menu = vm.menu {
                DetailRecipeView(
                    menu: menu,
                    allMenus: [],
                    cafeId: vm.cafeId ?? ""
                )
            }
            else if let msg = vm.errorMessage {
                VStack(spacing: 12) {
                    Text("상세 정보를 불러오지 못했어요")
                        .font(.headline)
                    Text(msg)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                
            } else {
                VStack { Spacer(); ProgressView(); Spacer() }
            }
        }
        .task {
            await vm.fetchRecipeDetail(userId: userId, recipeId: recipeId)
        }
    }
}
