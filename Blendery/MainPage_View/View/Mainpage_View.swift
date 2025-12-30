import SwiftUI
import UIKit

struct Mainpage_View: View {

    @State private var showStoreModal: Bool = false
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "즐겨찾기"

    // ✅ 즐겨찾기 토글 상태 유지
    @State private var cards: [MenuCardModel] = menuCardsMock

    // ✅ 검색창 포커스(=키보드 올라옴) 감지
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Mainpage_TopMenu(
                    onTapStoreButton: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showStoreModal = true
                        }
                    },
                    categories: categories,
                    selectedCategory: $selectedCategory
                )
                .background(Color.white)

                Mainpage_ScrollView(
                    selectedCategory: selectedCategory,
                    cards: $cards
                )
                .id(selectedCategory)
            }

            // ✅ 검색 오버레이
            if isSearchFocused {
                searchOverlay
                    .transition(.opacity)
                    .zIndex(50)
            }

            // ✅ 매장 선택 모달
            if showStoreModal {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showStoreModal = false
                        }
                    }
                    .zIndex(90)

                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Color.white
                            .frame(height: geo.safeAreaInsets.top)

                        StoreSelectPanel(
                            onClose: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showStoreModal = false
                                }
                            }
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .background(Color.white)
                    .clipShape(
                        RoundedCorner(
                            radius: 16,
                            corners: [.bottomLeft, .bottomRight]
                        )
                    )
                    .transition(.move(edge: .top))
                    .ignoresSafeArea(edges: .top)
                }
                .zIndex(100)
            }
        }
        .navigationBarBackButtonHidden(true)

        .safeAreaInset(edge: .bottom, spacing: 0) {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    SearchBarView(
                        text: $searchText,
                        placeholder: "검색",
                        onSearchTap: { print("검색:", searchText) },
                        focus: $isSearchFocused,
                        isFocused: Binding(
                            get: { isSearchFocused },
                            set: { isSearchFocused = $0 }
                        )
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 12)

                    Color.clear
                        .frame(height: geo.safeAreaInsets.bottom)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.95))
                .clipShape(
                    RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                )
                .overlay(
                    RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
            }
            .frame(height: 74)
        }
    }
}

// MARK: - ✅ 여기! 검색 오버레이(세로 음료 리스트)
private extension Mainpage_View {
    var searchOverlay: some View {
        let items = searchedItems
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return ZStack(alignment: .top) {
            Color.white
                .ignoresSafeArea()
                .onTapGesture {
                    isSearchFocused = false
                    hideKeyboard()
                }

            // ✅✅✅ 바로 "여기"에 넣으면 됨 (원래 ScrollView 자리)
            if !q.isEmpty && items.isEmpty {
                VStack {
                    Spacer()

                    SearchEmpty_View()
                        .padding(.bottom, -125)   // ✅ 검색창 테두리 기준 위로 100pt

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 74) // ✅ 아래 검색창 패널(고정 높이) 만큼 자리 예약
                }

            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(items) { item in
                            MenuListRow(
                                model: item,
                                onToggleBookmark: {
                                    if let idx = cards.firstIndex(where: { $0.id == item.id }) {
                                        cards[idx].isBookmarked.toggle()
                                    }
                                }
                            )
                        }
                    }
                    .padding(.bottom, 74)
                }
                .contentShape(Rectangle())
                .onTapGesture { }
            }
        }
    }

    var searchedItems: [MenuCardModel] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty {
            return cards
        }
        return cards.filter {
            $0.title.localizedCaseInsensitiveContains(q) ||
            $0.subtitle.localizedCaseInsensitiveContains(q) ||
            $0.lines.joined(separator: " ").localizedCaseInsensitiveContains(q)
        }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

// MARK: - RoundedCorner Shape
private struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview("Mainpage_View") {
    NavigationStack {
        Mainpage_View()
    }
}
