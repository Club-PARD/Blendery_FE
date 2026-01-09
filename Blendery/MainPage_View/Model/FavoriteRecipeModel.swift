//
//  FavoriteRecipeModel.swift
//  Blendery
//
//  Created by 박성준 on 1/9/26.
//

import Foundation

struct FavoriteRecipeResponse: Decodable {
    let cafeId: String
    let favorites: [FavoriteRecipe]
}

struct FavoriteRecipe: Decodable, Identifiable {
    let recipeId: UUID
    let title: String
    let category: String
    let hotThumbnailUrl: String?
    let iceThumbnailUrl: String?

    var id: UUID { recipeId }
}
