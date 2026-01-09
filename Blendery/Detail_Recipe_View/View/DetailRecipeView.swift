//
//  DetailRecipeView.swift
//  Blendery
//

import SwiftUI
import UIKit

struct DetailRecipeView: View {

    // MARK: - Inputs
    let menu: MenuCardModel
    let allMenus: [MenuCardModel]
    let cafeId: String

    // MARK: - State
    @State private var selectedTemperature: Temperature = .hot
    @State private var selectedSize: Size = .large

    @StateObject private var searchVM = SearchBarViewModel()
    @FocusState private var isSearchFieldFocused: Bool

    private struct RecipeNavID: Identifiable, Hashable {
        let id: UUID
    }
    @State private var selectedRecipe: RecipeNavID? = nil

    private var userId: String {
        SessionManager.shared.currentUserId ?? ""
    }

    // MARK: - Derived State
    private var optionKey: String {
        RecipeOptionKey.make(
            temperature: selectedTemperature,
            size: selectedSize
        )
    }

    private var optionBadgeTags: [String] {
        RecipeVariantType(rawValue: optionKey)?.optionTags ?? []
    }

    private var currentSteps: [RecipeStep] {
        menu.recipesByOption[optionKey]
        ?? menu.recipesByOption.values.first
        ?? []
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            VStack(spacing: 0) {

                // 🔖 타이틀 + 북마크
                RecipeTitle(
                    menu: menu,
                    optionTags: optionBadgeTags,
                    thumbnailURL: currentThumbnailURL,
                    onToggleFavorite: {
                        // 👉 여기서는 UI 토글만 확인 (서버는 추후 연결)
                        print("🔖 bookmark tapped")
                    }
                )
                .padding(22)

                // 📋 레시피 스텝
                RecipeStepList(
                    steps: currentSteps,
                    bottomInset: 200
                )
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

                Spacer(minLength: 0)
            }

            // 🔍 검색 오버레이
            if searchVM.isFocused {
                RecipeSearchOverlayView(
                    searchVM: searchVM,
                    focus: $isSearchFieldFocused,
                    onSelect: { recipeId in
                        selectedRecipe = RecipeNavID(id: recipeId)
                    }
                )
                .transition(.opacity)
                .zIndex(50)
            }
        }

        // 🔘 옵션 버튼
        .overlay(alignment: .bottomTrailing) {
            if !searchVM.isFocused {
                let showTemp = menu.availableTemps.count >= 2
                let showSize = menu.availableSizes.count >= 2

                OptionButton(
                    temperature: $selectedTemperature,
                    size: $selectedSize,
                    showTemperatureToggle: showTemp,
                    showSizeToggle: showSize
                )
                .padding(.trailing, 16)
                .padding(.bottom, 15)
            }
        }

        // MARK: - Life Cycle
        .onAppear {

            // 온도 1종
            if menu.availableTemps.count == 1 {
                selectedTemperature =
                    menu.availableTemps.contains(.ice) ? .ice : .hot
            }

            // 사이즈 1종
            if menu.availableSizes.count == 1 {
                selectedSize =
                    menu.availableSizes.contains(.extra) ? .extra : .large
            }
        }

        // 🔎 하단 검색바
        .safeAreaInset(edge: .bottom) {
            SearchBarView(
                vm: searchVM,
                placeholder: "메뉴 검색",
                onSearchTap: {
                    Task { await searchVM.search() }
                },
                focus: $isSearchFieldFocused
            )
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .background(Color.white.opacity(0.95))
        }

        // 🔁 검색 결과 → 다른 레시피
        .navigationDestination(item: $selectedRecipe) { nav in
            DetailRecipeViewByID(
                recipeId: nav.id,
                userId: userId
            )
        }

        // 🔄 Focus 동기화
        .onChange(of: searchVM.isFocused) { newValue in
            if isSearchFieldFocused != newValue {
                isSearchFieldFocused = newValue
            }
        }
        .onChange(of: isSearchFieldFocused) { newValue in
            if searchVM.isFocused != newValue {
                searchVM.isFocused = newValue
            }
        }

        // 🔙 네비게이션
        .navigationBarBackButtonHidden(true)
        .toolbar {

            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    UIApplication.shared.popToRoot(animated: true)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                }
            }
        }
    }
}

// MARK: - Private Helpers
private extension DetailRecipeView {

    var currentThumbnailURL: URL? {
        let s = (selectedTemperature == .hot)
            ? menu.hotThumbnailUrl
            : menu.iceThumbnailUrl

        guard let s, !s.isEmpty else { return nil }
        return URL(string: s)
    }
}
