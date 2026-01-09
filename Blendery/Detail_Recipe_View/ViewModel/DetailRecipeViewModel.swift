import Foundation
import Combine

@MainActor
final class DetailRecipeViewModel: ObservableObject {
    // MARK: - Bookmark State
    @Published var isBookmarked: Bool = false

    // 현재 카페 (MainpageViewModel에서 전달받을 값)
    var cafeId: String? = nil

    
    // MARK: - Data
    @Published var menu: MenuCardModel? = nil
    
    // MARK: - UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Option State (⭐️ 핵심)
    @Published var selectedTemperature: Temperature = .hot
    @Published var selectedSize: Size = .large
    
    // MARK: - Server Key (computed)
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
            isBookmarked = menu?.isBookmarked ?? false

            
            // ✅ 여기서 확인용 print
            print("현재 옵션 키:", optionKey)
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func toggleBookmark() {
        guard
            let cafeId,
            var menu = menu    // ⭐️ var로 꺼냄
        else { return }

        // 1️⃣ UI 즉시 반영 (optimistic update)
        menu.isBookmarked.toggle()
        self.menu = menu       // ⭐️ 다시 할당 (Published 갱신)

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
                // 2️⃣ 실패 시 롤백
                menu.isBookmarked.toggle()
                self.menu = menu

                print("❌ 상세 레시피 북마크 토글 실패")
            }
        }
    }
}
