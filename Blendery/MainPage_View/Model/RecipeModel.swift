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
    
    let hotThumbnailUrl: String?
    let iceThumbnailUrl: String?
    
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
    case HOT_EXTRA
    case ICE_LARGE
    case ICE_EXTRA
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

extension RecipeVariantType {

    /// OptionBadge에 표시할 UI용 태그
    var optionTags: [String] {
        switch self {
        case .HOT_LARGE:
            return ["HOT", "L"]
        case .HOT_EXTRA:
            return ["HOT", "XL"]
        case .ICE_LARGE:
            return ["ICE", "L"]
        case .ICE_EXTRA:
            return ["ICE", "XL"]
        case .OTHER:
            return []
        }
    }
}

//아이스 메뉴 토글 조정 코드 추후 효율적으로 병합 가능할듯
enum TempOption: Hashable { case hot, ice }
enum SizeOption: Hashable { case large, extra }

extension RecipeVariantType {
    var tempOption: TempOption? {
        switch self {
        case .HOT_LARGE, .HOT_EXTRA: return .hot
        case .ICE_LARGE, .ICE_EXTRA: return .ice
        case .OTHER: return nil
        }
    }

    var sizeOption: SizeOption? {
        switch self {
        case .HOT_LARGE, .ICE_LARGE: return .large
        case .HOT_EXTRA, .ICE_EXTRA: return .extra
        case .OTHER: return nil
        }
    }
}

extension MenuCardModel {
    
    // ✅ 메인 목록용 (RecipeModel → MenuCardModel)
    static func from(_ recipe: RecipeModel) -> MenuCardModel {
        
        let recipesByOption: [String: [RecipeStep]] =
        Dictionary(grouping: recipe.variants, by: { $0.type.rawValue })
            .mapValues { variants in
                variants.flatMap { variant in
                    variant.steps.map { RecipeStep(text: $0) }
                }
            }
        
        // ⭐️ 2. 기본 variant (fallback용)
        let defaultVariant =
        recipe.variants.first { $0.isDefault }
        ?? recipe.variants.first
        
        return MenuCardModel(
            id: recipe.recipeId,
            category: recipe.category,
            tags: [],
            title: recipe.title,
            subtitle: defaultVariant?.steps.first ?? "",
            lines: defaultVariant?.steps ?? [],          // (기존 UI용 임시 유지)
            recipesByOption: recipesByOption,            // ⭐️ 핵심
            isBookmarked: false,
            isImageLoading: false,
            imageName: nil,
            hotThumbnailUrl: recipe.hotThumbnailUrl,
            iceThumbnailUrl: recipe.iceThumbnailUrl
        )
    }
    
    // ✅ 검색 결과용 (SearchRecipeModel → MenuCardModel)
    static func fromSearch(_ model: SearchRecipeModel) -> MenuCardModel {
        MenuCardModel(
            id: model.recipeId,
            category: model.category,
            tags: searchTags(from: model),
            title: model.title,
            subtitle: "",
            lines: [],
            recipesByOption: [:],
            isBookmarked: false,
            isImageLoading: false,
            imageName: nil
        )
    }
    
    // 🔎 검색 전용 태그
    private static func searchTags(from model: SearchRecipeModel) -> [String] {
        var tags: [String] = []
        if model.signature { tags.append("SIGNATURE") }
        if model.new { tags.append("NEW") }
        return tags
    }
}


// 아이스 메뉴 토글 조정 코드 추후 효율적으로 extension끼리 병합 가능할듯
extension MenuCardModel {
    var availableTemps: Set<TempOption> {
        let keys = recipesByOption.keys
        var result = Set<TempOption>()
        if keys.contains("HOT_LARGE") || keys.contains("HOT_EXTRA") { result.insert(.hot) }
        if keys.contains("ICE_LARGE") || keys.contains("ICE_EXTRA") { result.insert(.ice) }
        return result
    }

    var availableSizes: Set<SizeOption> {
        let keys = recipesByOption.keys
        var result = Set<SizeOption>()
        if keys.contains("HOT_LARGE") || keys.contains("ICE_LARGE") { result.insert(.large) }
        if keys.contains("HOT_EXTRA") || keys.contains("ICE_EXTRA") { result.insert(.extra) }
        return result
    }
}

