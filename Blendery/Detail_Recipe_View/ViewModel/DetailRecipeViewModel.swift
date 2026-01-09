import Foundation
import Combine

@MainActor
final class DetailRecipeViewModel: ObservableObject {
    // 서버 연동용
    var cafeId: String? = nil

    @Published var menu: MenuCardModel? = nil

    // MARK: - UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Option State
    @Published var selectedTemperature: Temperature = .hot
    @Published var selectedSize: Size = .large

    var optionKey: String {
        RecipeOptionKey.make(
            temperature: selectedTemperature,
            size: selectedSize
        )
    }

    var optionBadgeTags: [String] {
        RecipeVariantType(rawValue: optionKey)?.optionTags ?? []
    }

    var currentSteps: [RecipeStep] {
        menu?.recipesByOption[optionKey]
        ?? menu?.recipesByOption.values.first
        ?? []
    }
    
    // MARK: - API
        func fetchRecipeDetail(
            userId: String,
            recipeId: UUID
        ) async {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            do {
                let recipe = try await APIClient.shared.fetchRecipeDetail(recipeId: recipeId)
                menu = MenuCardModel.from(recipe)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    
    func toggleBookmark() {
        guard
            let cafeId,
            var menu = menu
        else { return }

        // ✅ 1) UI 즉시 반영
        menu.isBookmarked.toggle()
        self.menu = menu

        // ✅ 2) 서버 호출
        Task {
            do {
                _ = try await APIClient.shared.toggleFavorite(
                    request: FavoriteToggleRequest(
                        cafeId: cafeId,
                        recipeId: menu.id,
                        recipeVariantId: menu.variantId
                    )
                )
            } catch {
                // ❌ 실패 시 롤백
                menu.isBookmarked.toggle()
                self.menu = menu
                print("❌ 상세 레시피 북마크 토글 실패")
            }
        }
    }
    // 서버 토글
    func toggleBookmarkOnServer(
        recipeId: UUID,
        variantId: Int
    ) async throws -> Bool {

        guard let cafeId else {
            throw URLError(.userAuthenticationRequired)
        }

        let result = try await APIClient.shared.toggleFavorite(
            request: FavoriteToggleRequest(
                cafeId: cafeId,
                recipeId: recipeId,
                recipeVariantId: variantId
            )
        )

        return result   // 서버가 내려준 최종 favorite 상태
    }
}
