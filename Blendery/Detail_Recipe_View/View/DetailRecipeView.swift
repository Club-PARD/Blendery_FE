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
    let menu: MenuCardModel
    let allMenus: [MenuCardModel]
    let cafeId: String

    // 🔖 북마크 UI 상태 (서버랑 연결할 핵심)
    @State private var isBookmarked: Bool

    init(menu: MenuCardModel, allMenus: [MenuCardModel], cafeId: String) {
        self.menu = menu
        self.allMenus = allMenus
        self.cafeId = cafeId
        _isBookmarked = State(initialValue: menu.isBookmarked)
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

                // 🔖 타이틀 + 북마크 (UI 그대로)
                RecipeTitle(
                    menu: menu,
                    optionTags: optionBadgeTags,
                    thumbnailURL: currentThumbnailURL,
                    isBookmarked: $isBookmarked,
                    onToggleFavorite: toggleBookmark   // ⭐️ 서버 연결
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
            if menu.availableTemps.count == 1 {
                selectedTemperature =
                    menu.availableTemps.contains(.ice) ? .ice : .hot
            }

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
        print("📤 [Bookmark Toggle]")
        print("   cafeId:", cafeId)
        print("   recipeId:", menu.id)
        print("   variantId:", menu.variantId)
        
        let previous = isBookmarked
        isBookmarked.toggle()   // 1️⃣ UI 즉시 반영

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
                isBookmarked = previous
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

