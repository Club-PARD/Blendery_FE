//
//  DetailRecipeView.swift
//  Blendery
//
//  Created by 박영언 on 12/26/25.
//

//
//  DetailRecipeView.swift
//  Blendery
//

import SwiftUI
import UIKit

struct DetailRecipeView: View {
    let menu: MenuCardModel
    let allMenus: [MenuCardModel]        // ✅ 전체 메뉴 리스트를 같이 받음
    
    @StateObject private var vm = DetailRecipeViewModel()
    
    @StateObject private var searchVM = SearchBarViewModel()
    @FocusState private var isSearchFieldFocused: Bool
    
    private struct RecipeNavID: Identifiable, Hashable { 
        let id: UUID
    }
    
    @State private var selectedRecipe: RecipeNavID? = nil
    
    var body: some View {
        ZStack {
            // ✅ 기본 상세 화면
            VStack(spacing: 0) {
                RecipeTitle(
                    menu: menu,
                    optionTags: vm.optionBadgeTags,
                    thumbnailURL: currentThumbnailURL
                )
                    .padding(22)
                
                // ✅ (기본) 현재 메뉴의 레시피 step은 그대로
//                RecipeStepList(steps: vm.currentSteps)
//                    .padding(16)
                
                ScreenshotShield {
                    RecipeStepList(steps: vm.currentSteps, bottomInset: 200)
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity) // ✅ 스크롤 영역 높이 확보
                .clipped()
                
                Spacer(minLength: 0)
            }
            
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
        .overlay(alignment: .bottomTrailing) {
            if !searchVM.isFocused {   // ✅ 검색중이면 숨김
                let showTemp = menu.availableTemps.count >= 2
                let showSize = menu.availableSizes.count >= 2

                OptionButton(
                    temperature: $vm.selectedTemperature,
                    size: $vm.selectedSize,
                    showTemperatureToggle: showTemp,
                    showSizeToggle: showSize
                )
                .padding(.trailing, 16)
                .padding(.bottom, 15)
            }
        }
        .onAppear {
            vm.menu = menu

            // 아이스 메뉴 토글 조정 코드
            // ✅ 온도가 1종이면 그 값으로 강제 고정
            if menu.availableTemps.count == 1 {
                vm.selectedTemperature = menu.availableTemps.contains(.ice) ? .ice : .hot
            }

            // ✅ 사이즈가 1종이면 그 값으로 강제 고정
            if menu.availableSizes.count == 1 {
                vm.selectedSize = menu.availableSizes.contains(.extra) ? .extra : .large
            }
        }
        // ✅ 하단 검색창 고정
        .safeAreaInset(edge: .bottom, spacing: 0) {
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
        // ✅ 검색 결과 눌러서 다른 메뉴 상세로 이동
        .navigationDestination(item: $selectedRecipe) { nav in
            DetailRecipeViewByID(
                recipeId: nav.id
            )
        }
        // ✅ FocusState 동기화(메인페이지 방식)
        .onChange(of: searchVM.isFocused) { newValue in
            if isSearchFieldFocused != newValue { isSearchFieldFocused = newValue }
        }
        .onChange(of: isSearchFieldFocused) { newValue in
            if searchVM.isFocused != newValue { searchVM.isFocused = newValue }
        }
    }
}

// MARK: - 메인페이지처럼 "전체 메뉴 리스트" 오버레이
private extension DetailRecipeView {
    
    var searchedMenus: [MenuCardModel] {
        let q = searchVM.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return allMenus }
        
        return allMenus.filter {
            $0.title.localizedCaseInsensitiveContains(q) ||
            $0.subtitle.localizedCaseInsensitiveContains(q) ||
            $0.lines.joined(separator: " ").localizedCaseInsensitiveContains(q)
        }
    }
    
    var searchOverlay: some View {
        let results = searchVM.results
        let q = searchVM.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return ZStack(alignment: .top) {
            Color.white
                .ignoresSafeArea()
                .onTapGesture { closeSearch() }
            
            if searchVM.isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 74) }
            }
            else if !q.isEmpty && results.isEmpty {
                VStack {
                    Spacer()
                    Text("검색 결과가 없어요")
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 74) }
            }
            else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(results, id: \.recipeId) { r in
                            SearchResultRow(
                                title: r.title,        // ✅ 너희 실제 필드명으로
                                subtitle: r.category    // ✅ 너희 실제 필드명으로
                            )
                            .onTapGesture {
                                selectedRecipe = RecipeNavID(id: r.recipeId)   // ✅ UUID로 이동
                                closeSearch()
                            }
                        }
                    }
                    .padding(.bottom, 74)
                }
            }
        }
    }
    
    func closeSearch() {
        searchVM.close()
        isSearchFieldFocused = false
        hideKeyboard()
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
    
    private var currentThumbnailURL: URL? {
        let s = (vm.selectedTemperature == .hot) ? menu.hotThumbnailUrl : menu.iceThumbnailUrl
        guard let s, !s.isEmpty else { return nil }
        return URL(string: s)
    }
}

private struct SearchResultRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(subtitle).font(.subheadline).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}



#Preview {
    let previewMenu = MenuCardModel(
        id: UUID(),
        category: "커피",
        tags: [],
        title: "카페모카",
        subtitle: "에스프레소 2샷",
        lines: [],   // 👈 currentSteps는 VM에서 사용
        recipesByOption: [
            "ICE_LARGE": [
                RecipeStep(text: "얼음 컵에 우유"),
                RecipeStep(text: "에스프레소 2샷"),
                RecipeStep(text: "초코 시럽")
            ],
            "HOT_EXTRA": [
                RecipeStep(text: "따뜻한 우유"),
                RecipeStep(text: "에스프레소 3샷"),
                RecipeStep(text: "초코 시럽")
            ]
        ],
        isBookmarked: false,
        isImageLoading: false,
        imageName: nil
    )

    NavigationStack {
        DetailRecipeView(
            menu: previewMenu,
            allMenus: [previewMenu]
        )
    }
}
