//
//  FavoriteViewModel.swift
//  Blendery
//
//  Created by 박영언 on 1/10/26.
//
import SwiftUI
import Combine

@MainActor
final class FavoriteViewModel: ObservableObject {

    @Published var isFavorite: Bool = false
    @Published var isLoading = false

    func toggle(
        cafeId: String,
        recipeId: UUID,
        recipeVariantId: Int
    ) {
        isLoading = true

        Task {
            do {
                let result = try await APIClient.shared.toggleFavorite(
                    request: FavoriteToggleRequest(
                        cafeId: cafeId,
                        recipeId: recipeId,
                        recipeVariantId: recipeVariantId
                    )
                )

                self.isFavorite = result
            } catch {
                print("❌ toggle favorite failed:", error)
            }

            isLoading = false
        }
    }
}
