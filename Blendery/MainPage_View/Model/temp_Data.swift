////
////  temp_Data.swift
////  Blendery
////
////  Created by 박성준 on 12/28/25.
////
//
import Foundation

let categories: [String] = [
    "즐겨찾기",
    "시즌메뉴",
    "커피",
    "콜드브루",
    "논커피",
    "에이드&과일주스",
    "블렌디드",
    "티"
]

struct MenuCardModel: Identifiable, Hashable {
    let id: UUID
    let category: String
    let tags: [String]          // ✅ 누락돼서 에러났던 부분
    let title: String
    let subtitle: String
    let lines: [String]
    var isBookmarked: Bool

    var isImageLoading: Bool
    var imageName: String?
    
    let hotThumbnailUrl: String?
    let iceThumbnailUrl: String?
    
    let recipesByOption: [String: [RecipeStep]]

    init(
        id: UUID = UUID(),
        category: String,
        tags: [String] = [],
        title: String,
        subtitle: String,
        lines: [String],
        recipesByOption: [String: [RecipeStep]] = [:],
        isBookmarked: Bool,
        isImageLoading: Bool = false,
        imageName: String? = nil,
        hotThumbnailUrl: String? = nil,
        iceThumbnailUrl: String? = nil
    ) {
        self.id = id
        self.category = category
        self.tags = tags
        self.title = title
        self.subtitle = subtitle
        self.lines = lines
        self.recipesByOption = recipesByOption
        self.isBookmarked = isBookmarked
        self.isImageLoading = isImageLoading
        self.imageName = imageName
        self.hotThumbnailUrl = hotThumbnailUrl
        self.iceThumbnailUrl = iceThumbnailUrl
    }
}
