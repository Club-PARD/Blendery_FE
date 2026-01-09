import SwiftUI
import Combine

// MARK: - Toast
struct ToastData: Identifiable, Equatable {
    let id = UUID()
    let iconName: String?
    let message: String
}

// MARK: - MainpageViewModel
@MainActor
final class MainpageViewModel: ObservableObject {

    // UI → Server category 매핑
    private let categoryMap: [String: String] = [
        "커피": "COFFEE",
        "콜드브루": "COLD_BREW",
        "디카페인": "DECAFEINE",
        "논커피": "NON_COFFEE",
        "블렌디드": "BLENDED",
        "티": "TEA",
        "에이드&과일주스": "ADE"
    ]

    func serverCategory(from uiCategory: String) -> String? {
        categoryMap[uiCategory]
    }

    // MARK: - State
    @Published var cards: [MenuCardModel] = []
    @Published var favoriteCards: [MenuCardModel] = []
    @Published var toast: ToastData? = nil
    @Published var isLoading: Bool = false

    // ⭐️ 현재 선택된 카페 컨텍스트
    @Published var currentCafeId: String? = nil

    init() {}

    // MARK: - Recipes
    func fetchRecipes(
        franchiseId: String,
        category: String? = nil,
        favorite: Bool? = nil
    ) async {
        do {
            let recipes = try await APIClient.shared.fetchRecipes(
                franchiseId: franchiseId,
                category: category,
                favorite: favorite
            )

            self.cards = recipes.map { MenuCardModel.from($0) }

        } catch {
            print("❌ 레시피 목록 조회 실패:", error)
        }
    }

    func normalItems(for selectedCategory: String) -> [MenuCardModel] {
        guard let serverCategory = categoryMap[selectedCategory] else { return [] }
        return cards.filter { $0.category == serverCategory }
    }

    // MARK: - Bookmark (Main Tab)
    /// 메인 탭: 아이콘 토글
    func toggleBookmarkFromMain(id: UUID) {
        guard
            let idx = cards.firstIndex(where: { $0.id == id }),
            let cafeId = currentCafeId
        else { return }

        // 1️⃣ UI 즉시 반영
        cards[idx].isBookmarked.toggle()
        let isBookmarked = cards[idx].isBookmarked

        toast = ToastData(
            iconName: "토스트 체크",
            message: isBookmarked
                ? "즐겨찾기에 추가되었습니다."
                : "즐겨찾기가 해제되었습니다."
        )

        // 2️⃣ 서버 토글
        Task {
            do {
                _ = try await APIClient.shared.toggleFavorite(
                    request: FavoriteToggleRequest(
                        cafeId: cafeId,
                        recipeId: cards[idx].id,
                        recipeVariantId: cards[idx].variantId
                    )
                )
            } catch {
                // ❌ 실패 시 롤백
                cards[idx].isBookmarked.toggle()
                toast = ToastData(
                    iconName: "exclamationmark.triangle",
                    message: "즐겨찾기 변경에 실패했습니다."
                )
            }
        }
    }

    // MARK: - Bookmark (Favorite Tab)
    /// 즐겨찾기 탭: 카드 제거
    func removeBookmarkFromFavorites(id: UUID) {
        guard let cafeId = currentCafeId else { return }

        // 1️⃣ 즐겨찾기 리스트 제거
        favoriteCards.removeAll { $0.id == id }

        // 2️⃣ 메인 카드 상태 동기화
        if let idx = cards.firstIndex(where: { $0.id == id }) {
            cards[idx].isBookmarked = false
        }

        toast = ToastData(
            iconName: "토스트 체크",
            message: "즐겨찾기가 해제되었습니다."
        )

        // 3️⃣ 서버 토글
        Task {
            do {
                guard let target = cards.first(where: { $0.id == id }) else { return }

                _ = try await APIClient.shared.toggleFavorite(
                    request: FavoriteToggleRequest(
                        cafeId: cafeId,
                        recipeId: target.id,
                        recipeVariantId: target.variantId
                    )
                )
            } catch {
                toast = ToastData(
                    iconName: "exclamationmark.triangle",
                    message: "즐겨찾기 해제에 실패했습니다."
                )
            }
        }
    }

    // MARK: - Favorites Load
    func loadFavoritesForMyCafe() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let cafes = try await APIClient.shared.fetchMyCafes()
            guard let cafeId = cafes.first?.cafeId else {
                toast = ToastData(
                    iconName: "exclamationmark.triangle",
                    message: "접근 가능한 매장이 없습니다."
                )
                return
            }

            // ⭐️ 현재 카페 저장
            self.currentCafeId = cafeId

            let res = try await APIClient.shared.fetchFavorites(cafeId: cafeId)

            self.favoriteCards = res.favorites.map {
                MenuCardModel.fromFavorite($0.toRecipeModel())
            }

        } catch {
            print("❌ 즐겨찾기 불러오기 실패:", error)
            toast = ToastData(
                iconName: "exclamationmark.triangle",
                message: "즐겨찾기 불러오기 실패"
            )
        }
    }

    // MARK: - Toast
    func clearToast() {
        toast = nil
    }

    // MARK: - Masonry
    func distributeMasonry(
        items: [MenuCardModel],
        heights: [UUID: CGFloat],
        spacing: CGFloat = 17,
        defaultHeight: CGFloat = 200
    ) -> (left: [MenuCardModel], right: [MenuCardModel]) {

        var left: [MenuCardModel] = []
        var right: [MenuCardModel] = []
        var leftH: CGFloat = 0
        var rightH: CGFloat = 0

        for item in items {
            let h = heights[item.id] ?? defaultHeight
            if leftH <= rightH {
                left.append(item)
                leftH += h + spacing
            } else {
                right.append(item)
                rightH += h + spacing
            }
        }
        return (left, right)
    }
}


//  검색창 뷰모델
@MainActor
final class SearchBarViewModel: ObservableObject {
    
    @Published var text: String = ""
    @Published var isFocused: Bool = false
    
    // ⭐️ 추가
    @Published var results: [SearchRecipeModel] = []
    @Published var isLoading: Bool = false
    
    private var userId: String? {
        SessionManager.shared.currentUserId
    }
    
    var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func open() { isFocused = true }
    func clearText() {
        text = ""
        results = []
    }
    
    func close() {
        text = ""
        results = []
        isFocused = false
    }
    
    // ⭐️ 서버 검색
    func search() async {
        guard
            let userId,
            hasText
        else {
            results = []
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            results = try await APIClient.shared.searchRecipes(
                keyword: text
            )
        } catch {
            print("❌ 검색 실패:", error)
            results = []
        }
    }
}


//  탑메뉴 뷰모델
@MainActor
final class TopMenuViewModel: ObservableObject {
    @Published var categoryFrames: [String: CGRect] = [:]
    
    let categories: [String]
    
    private let favoriteRed = Color(red: 238/255, green: 34/255, blue: 42/255)
    private let seasonBlue = Color(red: 36/255, green: 60/255, blue: 131/255)
    
    init(categories: [String]) {
        self.categories = categories
    }
    
    func textColor(for category: String) -> Color {
        switch category {
        case "즐겨찾기":
            return favoriteRed
        case "시즌메뉴":
            return seasonBlue
        default:
            return .black
        }
    }
    
    func indicatorColor(for selectedCategory: String) -> Color {
        switch selectedCategory {
        case "즐겨찾기":
            return favoriteRed
        case "시즌메뉴":
            return seasonBlue
        default:
            return .black
        }
    }
    
    var favoriteKey: String { categories.first ?? "즐겨찾기" }
    
    func isFavorite(_ category: String) -> Bool {
        category == favoriteKey
    }
}
