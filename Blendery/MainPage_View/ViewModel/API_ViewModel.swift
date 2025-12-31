//
//  API_ViewModel.swift
//  Blendery
//
//  Created by 박성준 on 12/31/25.
//

import Foundation
import Combine

@MainActor
final class API_ViewModel: ObservableObject {

    //  결과 데이터
    @Published var recipeList: [RecipeModel] = []

    //  UI 상태
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    /// 화면에서 버튼/필터 바뀔 때 호출
    func fetchRecipeList(franchiseId: String, category: String?, favorite: Bool?) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let result = try await BlenderyAPI.shared.searchRecipes(
                    franchiseId: franchiseId,
                    category: category,
                    favorite: favorite
                )
                self.recipeList = result
                self.isLoading = false
            } catch {
                self.recipeList = []
                self.isLoading = false
                self.errorMessage = String(describing: error)
            }
        }
    }

    /// async/await로 쓰고 싶을 때(선택)
    func fetchRecipeListAsync(franchiseId: String, category: String?, favorite: Bool?) async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await BlenderyAPI.shared.searchRecipes(
                franchiseId: franchiseId,
                category: category,
                favorite: favorite
            )
            self.recipeList = result
            self.isLoading = false
        } catch {
            self.recipeList = []
            self.isLoading = false
            self.errorMessage = String(describing: error)
        }
    }
}
