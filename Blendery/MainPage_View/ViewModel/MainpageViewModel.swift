import SwiftUI
import Combine

//  토스트 데이터 타입 추가 (onChange 요구사항 때문에 Equatable)
struct ToastData: Equatable {
    let message: String
}

@MainActor
final class MainpageViewModel: ObservableObject {

    @Published var cards: [MenuCardModel]
    @Published var toast: ToastData? = nil

    init(cards: [MenuCardModel] = menuCardsMock) {
        self.cards = cards
    }

    var favoriteItems: [MenuCardModel] {
        cards.filter { $0.isBookmarked }
    }

    func normalItems(for selectedCategory: String) -> [MenuCardModel] {
        cards.filter { $0.category == selectedCategory }
    }

    func toggleBookmark(id: UUID) {
        guard let idx = cards.firstIndex(where: { $0.id == id }) else { return }

        cards[idx].isBookmarked.toggle()

        //  해제됐을 때만 토스트
        if cards[idx].isBookmarked == false {
            toast = ToastData(message: "즐겨찾기가 해제되었습니다.")
        }
    }

    //  Mainpage_View에서 호출하던 함수 추가
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
}

//  검색창 뷰모델
@MainActor
final class SearchBarViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var isFocused: Bool = false

    var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func open() { isFocused = true }
    func clearText() { text = "" }

    func close() {
        text = ""
        isFocused = false
    }
}

//  탑메뉴 뷰모델
@MainActor
final class TopMenuViewModel: ObservableObject {
    @Published var categoryFrames: [String: CGRect] = [:]

    let categories: [String]
    let favoriteOrange = Color(red: 0.89, green: 0.19, blue: 0)

    init(categories: [String]) {
        self.categories = categories
    }

    var favoriteKey: String { categories.first ?? "즐겨찾기" }

    func isFavorite(_ category: String) -> Bool {
        category == favoriteKey
    }

    func indicatorColor(for selectedCategory: String) -> Color {
        isFavorite(selectedCategory) ? favoriteOrange : .black
    }

    func textColor(for category: String) -> Color {
        isFavorite(category) ? favoriteOrange : .black
    }
}
