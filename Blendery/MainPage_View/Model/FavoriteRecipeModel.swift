//
//  FavoriteRecipeModel.swift
//  Blendery
//
//  Created by 박성준 on 1/9/26.
//

import Foundation

struct FavoriteResponse: Decodable {
    let cafeId: String
    let favorites: [FavoriteRecipeItem]
}

// 즐겨찾기 응답용 모델 (variant 단수형)
struct FavoriteRecipeItem: Decodable {
    let recipeId: UUID
    let title: String
    let category: String
    let hotThumbnailUrl: String?
    let iceThumbnailUrl: String?
    let variant: RecipeVariantModel  // 단수형
    
    // RecipeModel로 변환
    func toRecipeModel() -> RecipeModel {
        RecipeModel(
            recipeId: recipeId,
            title: title,
            category: category,
            hotThumbnailUrl: hotThumbnailUrl,
            iceThumbnailUrl: iceThumbnailUrl,
            variants: [variant]  // 단수형 variant를 배열로 변환
        )
    }
}

struct FavoriteToggleRequest: Encodable {
    let cafeId: String
    let recipeId: UUID
    let recipeVariantId: Int
}


struct FavoriteToggleResponse: Decodable {
    let favorite: Bool
}
