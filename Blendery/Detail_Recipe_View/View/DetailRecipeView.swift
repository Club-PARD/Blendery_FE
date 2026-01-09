//
//  DetailRecipeView.swift
//  Blendery
//

//
//  DetailRecipeView.swift
//  Blendery
//

import SwiftUI
import UIKit

struct DetailRecipeView: View {

    // MARK: - Inputs
    @State private var menu: MenuCardModel

    let allMenus: [MenuCardModel]
    let cafeId: String

    init(menu: MenuCardModel, allMenus: [MenuCardModel], cafeId: String) {
        _menu = State(initialValue: menu)
        self.allMenus = allMenus
        self.cafeId = cafeId
    }


    // MARK: - Option State
    @State private var selectedTemperature: Temperature = .hot
    @State private var selectedSize: Size = .large

    // MARK: - Search
    @StateObject private var searchVM = SearchBarViewModel()
    @FocusState private var isSearchFieldFocused: Bool

    // MARK: - Navigation
    private struct RecipeNavID: Identifiable, Hashable {
        let id: UUID
    }
    @State private var selectedRecipe: RecipeNavID? = nil

    private var userId: String {
        SessionManager.shared.currentUserId ?? ""
    }

    // MARK: - Derived
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

                RecipeTitle(
                    menu: menu,
                    optionTags: optionBadgeTags,
                    thumbnailURL: currentThumbnailURL,
                    isBookmarked: Binding(
                        get: { menu.isBookmarked },
                        set: { menu.isBookmarked = $0 }
                    ),
                    onToggleFavorite: toggleBookmark
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

        // 🔘 옵션 버튼 (UI 그대로)
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
            // 1️⃣ 옵션 초기 세팅 (기존 코드)
            if menu.availableTemps.count == 1 {
                selectedTemperature =
                    menu.availableTemps.contains(.ice) ? .ice : .hot
            }

            if menu.availableSizes.count == 1 {
                selectedSize =
                    menu.availableSizes.contains(.extra) ? .extra : .large
            }

            // 2️⃣ ⭐️ 서버 기준 북마크 상태 동기화 (이게 핵심)
            Task {
                do {
                    let favorites = try await APIClient.shared.fetchFavorites(cafeId: cafeId)

                    let isFav = favorites.favorites.contains {
                        $0.recipeId == menu.id
                    }

                    menu.isBookmarked = isFav
                    print("🔄 bookmark synced from server:", isFav)

                } catch {
                    print("❌ failed to sync bookmark:", error)
                }
            }
        }


        // 🔎 하단 검색바
        .safeAreaInset(edge: .bottom) {
            SearchBarView(
                vm: searchVM,
                placeholder: "메뉴 검색",
                onSearchTap: { Task { await searchVM.search() } },
                focus: $isSearchFieldFocused
            )
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .background(Color.white.opacity(0.95))
        }

        // 🔁 검색 → 다른 레시피
        .navigationDestination(item: $selectedRecipe) { nav in
            DetailRecipeViewByID(
                recipeId: nav.id,
                userId: userId,
                cafeId: cafeId
            )
        }

        // 🔄 포커스 동기화
        .onChange(of: searchVM.isFocused) { v in
            if isSearchFieldFocused != v { isSearchFieldFocused = v }
        }
        .onChange(of: isSearchFieldFocused) { v in
            if searchVM.isFocused != v { searchVM.isFocused = v }
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

// MARK: - ⭐️ 서버 북마크 토글 (핵심)
// MARK: - ⭐️ 서버 북마크 토글 (핵심)
private extension DetailRecipeView {
    
    func toggleBookmark() {
        let previous = menu.isBookmarked
        
        // 1️⃣ UI 즉시 반영
        menu.isBookmarked.toggle()
        
        Task {
            do {
                _ = try await APIClient.shared.toggleFavorite(
                    request: FavoriteToggleRequest(
                        cafeId: cafeId,
                        recipeId: menu.id,
                        recipeVariantId: menu.variantId
                    )
                )
                print("✅ bookmark server synced")
            } catch {
                // 2️⃣ 실패 시 롤백
                menu.isBookmarked = previous
                print("❌ bookmark toggle failed:", error)
            }
        }
    }

    var currentThumbnailURL: URL? {
        let s = (selectedTemperature == .hot)
            ? menu.hotThumbnailUrl
            : menu.iceThumbnailUrl

        guard let s, !s.isEmpty else { return nil }
        return URL(string: s)
    }
}

