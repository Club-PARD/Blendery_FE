//
//  MainModels_ViewModels.swift
//  Blendery
//
//  ✅ TopMenuViewModel + SearchBarViewModel + MainpageViewModel 통합
//

import SwiftUI
import Combine
import Foundation

// ===============================
//  토스트 데이터
// ===============================
struct ToastData: Identifiable, Equatable {
    let id = UUID()
    let iconName: String?
    let message: String
}

// ===============================
//  MainpageViewModel
// ===============================
@MainActor
final class MainpageViewModel: ObservableObject {

    // -------------------------------
    //  서버 데이터 변수
    // -------------------------------
    @Published private(set) var allCards: [MenuCardModel] = []

    // ✅ 기존 코드 호환용(DetailRecipeViewByID에서 vm.cards 쓰는 경우 방지)
    @Published var cards: [MenuCardModel] = []

    // -------------------------------
    //  UI 상태 변수
    // -------------------------------
    @Published var toast: ToastData? = nil

    // -------------------------------
    //  로컬 캐시 키
    // -------------------------------
    private let menuStorageKey = "blendery_menu_cache_v1"
    private let seasonBookmarkKey = "blendery_season_bookmark_ids_v1"

    // -------------------------------
    //  시즌 목데이터
    // -------------------------------
    private let seasonMock: [SeasonMenuMockItem] = SeasonMenuMockItem.items
    private var seasonMockIDs: Set<UUID> {
        Set(seasonMock.map { $0.recipeId })
    }

    // ✅ 시즌 즐겨찾기 저장 상태(UserDefaults로 유지)
    @Published private var seasonBookmarkedIDs: Set<UUID> = []

    // -------------------------------
    //  카테고리 매핑(기존 유지)
    // -------------------------------
    private let categoryMap: [String: String] = [
        "커피": "COFFEE",
        "콜드브루": "COLD_BREW",
        "디카페인": "DECAFEINE",
        "논커피": "NON_COFFEE",
        "블렌디드": "BLENDED",
        "티": "TEA",
        "에이드&과일주스": "ADE"
    ]

    // -------------------------------
    //  init
    // -------------------------------
    init() {
        loadMenuCacheFromDisk()
        loadSeasonBookmarksFromDisk()

        // ✅ cards도 초기 동기화
        cards = allCards
    }

    func serverCategory(from uiCategory: String) -> String? {
        categoryMap[uiCategory]
    }

    // ===============================
    //  ✅ 시즌 메뉴 (목데이터 -> MenuCardModel 변환)
    //  - 이미지: 에셋(imageName)만 사용
    //  - 상세 이동: recipeId(서버 UUID) 그대로
    // ===============================
    var seasonItems: [MenuCardModel] {
        seasonMock.map { m in
            MenuCardModel(
                id: m.recipeId,
                category: m.category,
                tags: [m.temperature],                 // 배지/텍스트로 활용 가능
                title: m.title,
                subtitle: m.temperature,               // SeasonCard에서 subtitle 보여주니까 온도 넣기
                lines: [],
                recipesByOption: [:],
                isBookmarked: seasonBookmarkedIDs.contains(m.recipeId),
                isImageLoading: false,
                imageName: m.imageName,                // ✅ 에셋 이름
                hotThumbnailUrl: nil,                  // ✅ 시즌은 서버 썸네일 안 씀
                iceThumbnailUrl: nil,                  // ✅ 시즌은 서버 썸네일 안 씀
                defaultOptionKey: "OTHER"
            )
        }
    }

    // ===============================
    //  ✅ 일반 카테고리 아이템(서버 메뉴)
    // ===============================
    func normalItems(for selectedCategory: String) -> [MenuCardModel] {
        guard let serverCategory = categoryMap[selectedCategory] else { return [] }
        return allCards.filter { $0.category == serverCategory }
    }

    // ===============================
    //  ✅ 서버 fetch (기존 유지 + 캐시 저장)
    // ===============================
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

            let newCards = recipes.map { MenuCardModel.from($0) }

            // ✅ 병합(즐겨찾기 유지)
            var merged = allCards
            for new in newCards {
                if let idx = merged.firstIndex(where: { $0.id == new.id }) {
                    var keep = new
                    keep.isBookmarked = merged[idx].isBookmarked
                    merged[idx] = keep
                } else {
                    merged.append(new)
                }
            }

            allCards = merged
            cards = merged

            // ✅ 로컬 캐시 저장
            saveMenuCacheToDisk()

        } catch {
            print("❌ 레시피 목록 조회 실패:", error)
        }
    }

    // ===============================
    //  ✅ 즐겨찾기 토글
    //  - 시즌: UserDefaults에 저장되는 “진짜 기능”
    //  - 서버메뉴: allCards isBookmarked 토글 + 캐시 저장
    // ===============================
    func toggleBookmark(id: UUID) {

        // 1) 시즌 목데이터면 시즌 즐겨찾기 처리
        if seasonMockIDs.contains(id) {
            toggleSeasonBookmark(id: id)
            return
        }

        // 2) 서버 메뉴면 기존처럼 토글
        guard let idx = allCards.firstIndex(where: { $0.id == id }) else { return }

        allCards[idx].isBookmarked.toggle()
        cards = allCards

        toast = ToastData(
            iconName: "토스트 체크",
            message: allCards[idx].isBookmarked ? "즐겨찾기에 추가되었습니다." : "즐겨찾기가 해제되었습니다."
        )

        // ✅ 서버 메뉴도 캐시에 저장해서 앱 재실행 유지
        saveMenuCacheToDisk()
    }

    private func toggleSeasonBookmark(id: UUID) {
        if seasonBookmarkedIDs.contains(id) {
            seasonBookmarkedIDs.remove(id)
            toast = ToastData(iconName: "토스트 체크", message: "즐겨찾기가 해제되었습니다.")
        } else {
            seasonBookmarkedIDs.insert(id)
            toast = ToastData(iconName: "토스트 체크", message: "즐겨찾기에 추가되었습니다.")
        }
        saveSeasonBookmarksToDisk()
    }

    func clearToast() {
        toast = nil
    }

    // ===============================
    //  masonry 분배 (기존 유지)
    // ===============================
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

// ===============================
//  ✅ 로컬 캐시 모델(서버 메뉴 저장용)
// ===============================
private struct MenuCardCacheItem: Codable {
    let id: UUID
    let category: String
    let tags: [String]
    let title: String
    let subtitle: String
    let lines: [String]
    let isBookmarked: Bool

    let hotThumbnailUrl: String?
    let iceThumbnailUrl: String?

    let recipesByOption: [String: [String]]
    let defaultOptionKey: String?
}

private extension MainpageViewModel {

    // -------------------------------
    //  서버 메뉴 캐시 저장
    // -------------------------------
    func saveMenuCacheToDisk() {

        let cacheItems: [MenuCardCacheItem] = allCards.map { card in
            MenuCardCacheItem(
                id: card.id,
                category: card.category,
                tags: card.tags,
                title: card.title,
                subtitle: card.subtitle,
                lines: card.lines,
                isBookmarked: card.isBookmarked,
                hotThumbnailUrl: card.hotThumbnailUrl,
                iceThumbnailUrl: card.iceThumbnailUrl,
                recipesByOption: card.recipesByOption.mapValues { steps in
                    steps.map { $0.text }   // RecipeStep(text:)
                },
                defaultOptionKey: card.defaultOptionKey
            )
        }

        do {
            let data = try JSONEncoder().encode(cacheItems)
            UserDefaults.standard.set(data, forKey: menuStorageKey)
        } catch {
            print("❌ Menu cache encode failed:", error)
        }
    }

    // -------------------------------
    //  서버 메뉴 캐시 로드
    // -------------------------------
    func loadMenuCacheFromDisk() {

        guard let data = UserDefaults.standard.data(forKey: menuStorageKey) else {
            allCards = []
            return
        }

        do {
            let cacheItems = try JSONDecoder().decode([MenuCardCacheItem].self, from: data)

            allCards = cacheItems.map { c in
                MenuCardModel(
                    id: c.id,
                    category: c.category,
                    tags: c.tags,
                    title: c.title,
                    subtitle: c.subtitle,
                    lines: c.lines,
                    recipesByOption: c.recipesByOption.mapValues { texts in
                        texts.map { RecipeStep(text: $0) }
                    },
                    isBookmarked: c.isBookmarked,
                    isImageLoading: false,
                    imageName: nil,
                    hotThumbnailUrl: c.hotThumbnailUrl,
                    iceThumbnailUrl: c.iceThumbnailUrl,
                    defaultOptionKey: c.defaultOptionKey
                )
            }

        } catch {
            print("❌ Menu cache decode failed:", error)
            allCards = []
        }
    }

    // -------------------------------
    //  시즌 즐겨찾기 저장/로드
    // -------------------------------
    func saveSeasonBookmarksToDisk() {
        let arr = seasonBookmarkedIDs.map { $0.uuidString }
        UserDefaults.standard.set(arr, forKey: seasonBookmarkKey)
    }

    func loadSeasonBookmarksFromDisk() {
        guard let arr = UserDefaults.standard.stringArray(forKey: seasonBookmarkKey) else {
            seasonBookmarkedIDs = []
            return
        }
        seasonBookmarkedIDs = Set(arr.compactMap { UUID(uuidString: $0) })
    }
}

// ===============================
//  SearchBarViewModel
// ===============================
@MainActor
final class SearchBarViewModel: ObservableObject {

    @Published var text: String = ""
    @Published var isFocused: Bool = false

    @Published var results: [SearchRecipeModel] = []
    @Published var isLoading: Bool = false

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

    func search() async {
        guard hasText else {
            results = []
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            results = try await APIClient.shared.searchRecipes(keyword: text)
        } catch {
            print("❌ 검색 실패:", error)
            results = []
        }
    }
}

// ===============================
//  TopMenuViewModel
// ===============================
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
