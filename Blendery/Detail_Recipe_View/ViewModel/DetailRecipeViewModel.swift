import Foundation
import Combine

@MainActor
final class DetailRecipeViewModel: ObservableObject {
    
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
            
            // ✅ 여기서 확인용 print
            print("현재 옵션 키:", optionKey)
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
