//
//  RecipeModel.swift
//  Blendery
//
//  Created by 박성준 on 12/31/25.
//

import Foundation

struct RecipeModel: Codable, Identifiable, Hashable {
    let recipeId: UUID
    let title: String
    let category: String
    let variants: [RecipeVariantModel]

    var id: UUID { recipeId }
}

struct RecipeVariantModel: Codable, Hashable {
    let variantId: Int
    let type: RecipeVariantType
    let steps: [String]
    let isDefault: Bool

    enum CodingKeys: String, CodingKey {
        case variantId, type, steps
        case isDefault = "default"   // JSON 키가 "default"라서 Swift에서 안전하게 이름 바꿈
    }
}

enum RecipeVariantType: String, Codable, Hashable {
    case HOT_LARGE
    case HOT_SMALL
    case ICE_LARGE
    case ICE_SMALL
    case OTHER

    // 서버가 새로운 타입을 내려줄 때 디코딩 죽지 않게 방어
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = RecipeVariantType(rawValue: raw) ?? .OTHER
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self == .OTHER ? "OTHER" : self.rawValue)
    }
}
