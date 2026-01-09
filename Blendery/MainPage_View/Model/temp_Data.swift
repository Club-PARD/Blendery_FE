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

    // MARK: - Identity
    let id: UUID                 // recipeId
    let variantId: Int           // ⭐️ 대표 variantId (중요)

    // MARK: - UI Info
    let category: String
    let tags: [String]
    let title: String
    let subtitle: String
    let lines: [String]

    // MARK: - State
    var isBookmarked: Bool

    // MARK: - Image
    var isImageLoading: Bool
    var imageName: String?
    let hotThumbnailUrl: String?
    let iceThumbnailUrl: String?

    // MARK: - Recipe
    let recipesByOption: [String: [RecipeStep]]

    // MARK: - Initializer
    init(
        id: UUID,
        variantId: Int,                 // ⭐️ 필수
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
        self.variantId = variantId      // ⭐️ 여기서 확정
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
