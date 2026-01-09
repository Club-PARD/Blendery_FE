import SwiftUI
import Combine

//  토스트 데이터 타입 (onChange 요구사항 때문에 Equatable)
struct ToastData: Identifiable, Equatable {
    let id = UUID()
    let iconName: String?
    let message: String
}

@MainActor
final class MainpageViewModel: ObservableObject {
    
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
    
    @Published var cards: [MenuCardModel] = []
    @Published var favoriteCards: [MenuCardModel] = []
    @Published var toast: ToastData? = nil
    @Published var isLoading: Bool = false
    
    init() {}
    
    func fetchRecipes(
        userId: String,
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
            
            // 🔄 서버 모델 → UI 모델 변환
            self.cards = recipes.map { recipe in
                MenuCardModel.from(recipe)
            }
            
        } catch {
            print("❌ 레시피 목록 조회 실패:", error)
        }
    }
    
    func normalItems(for selectedCategory: String) -> [MenuCardModel] {
        
        guard let serverCategory = categoryMap[selectedCategory] else {
            return []
        }
        
        return cards.filter { $0.category == serverCategory }
    }
    
    
    func toggleBookmark(id: UUID) {
        guard let idx = cards.firstIndex(where: { $0.id == id }) else { return }
        
        cards[idx].isBookmarked.toggle()
        cards = cards
        
        if cards[idx].isBookmarked == false {
            toast = ToastData(iconName: "토스트 체크", message: "즐겨찾기가 해제되었습니다.")
        } else {
            toast = ToastData(iconName: "토스트 체크", message: "즐겨찾기에 추가되었습니다.")
        }
    }
    
    func clearToast() {
        toast = nil
    }
    
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
    @MainActor
    func loadFavoritesForMyCafe() async {
        print("🔥 loadFavoritesForMyCafe CALLED")
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            print("➡️ 1) calling fetchMyCafes")
            let cafes = try await APIClient.shared.fetchMyCafes()
            print("✅ 1) cafes decoded count:", cafes.count)
            
            guard let cafeId = cafes.first?.cafeId else {
                print("⛔️ cafeId is nil")
                toast = ToastData(iconName: "exclamationmark.triangle", message: "접근 가능한 매장이 없습니다.")
                return
            }
            print("✅ 1) using cafeId:", cafeId)
            
            print("➡️ 2) calling fetchFavorites")
            let res = try await APIClient.shared.fetchFavorites(cafeId: cafeId)
            print("✅ 2) favorites decoded count:", res.favorites.count)
            
            // ⭐️ FavoriteRecipeItem → RecipeModel → MenuCardModel 변환
            self.favoriteCards = res.favorites.map { favoriteItem in
                let recipeModel = favoriteItem.toRecipeModel()
                return MenuCardModel.fromFavorite(recipeModel)
            }
            print("✅ 3) favoriteCards assigned:", self.favoriteCards.count)
            
        } catch is CancellationError {
            print("⚠️ loadFavorites task cancelled")
        } catch {
            print("❌ loadFavoritesForMyCafe FAILED:", error)
            toast = ToastData(iconName: "exclamationmark.triangle", message: "즐겨찾기 불러오기 실패")
        }
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
