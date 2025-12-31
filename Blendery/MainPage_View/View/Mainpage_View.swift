import SwiftUI
import UIKit

struct Mainpage_View: View {

    @State private var showStoreModal: Bool = false
    @State private var selectedCategory: String = "즐겨찾기"

    @State private var toastMessage: String = ""
    @State private var showToast: Bool = false

    @StateObject private var vm = MainpageViewModel()
    @StateObject private var searchVM = SearchBarViewModel()

    // categories를 프로퍼티 초기화에서 쓰는 게 불안정하면 init으로 박아주는 게 제일 안전
    @StateObject private var topMenuVM: TopMenuViewModel
    init() {
        _topMenuVM = StateObject(wrappedValue: TopMenuViewModel(categories: categories))
    }

    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                Mainpage_TopMenu(
                    onTapStoreButton: {
                        withAnimation(.easeInOut(duration: 0.25)) { showStoreModal = true }
                    },
                    selectedCategory: $selectedCategory,
                    vm: topMenuVM
                )
                .background(Color.white)

                Mainpage_ScrollView(
                    selectedCategory: selectedCategory,
                    vm: vm
                )
                .id(selectedCategory)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            if searchVM.isFocused {
                searchOverlay
                    .transition(.opacity)
                    .zIndex(50)
            }

            if showStoreModal {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) { showStoreModal = false }
                    }
                    .zIndex(90)

                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Color.white
                            .frame(height: geo.safeAreaInsets.top)

                        StoreSelectPanel(
                            onClose: {
                                withAnimation(.easeInOut(duration: 0.2)) { showStoreModal = false }
                            }
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .background(Color.white)
                    .clipShape(RoundedCorner(radius: 16, corners: [.bottomLeft, .bottomRight]))
                    .transition(.move(edge: .top))
                    .ignoresSafeArea(edges: .top)
                }
                .zIndex(100)
            }
        }
        .navigationBarBackButtonHidden(true)

        //  토스트 이벤트 처리
        .onChange(of: vm.toast) { newToast in
            guard let newToast else { return }
            presentToast(newToast.message)
            vm.clearToast()
        }

        //  FocusState 동기화
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

        .overlay(alignment: .bottom) {
            if showToast {
                ToastView(message: toastMessage)
                    .padding(.bottom, 74 + 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(999)
            }
        }

        .safeAreaInset(edge: .bottom, spacing: 0) {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    SearchBarView(
                        vm: searchVM,
                        placeholder: "검색",
                        onSearchTap: { print("검색:", searchVM.text) },
                        focus: $isSearchFieldFocused
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 12)

                    Color.clear
                        .frame(height: geo.safeAreaInsets.bottom)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
                .overlay(
                    RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
            }
            .frame(height: 74)
        }
    }
}

// MARK: - 검색 오버레이
private extension Mainpage_View {
    var searchOverlay: some View {
        let items = searchedItems
        let q = searchVM.text.trimmingCharacters(in: .whitespacesAndNewlines)

        return ZStack(alignment: .top) {
            Color.white
                .ignoresSafeArea()
                .onTapGesture { closeSearch() }

            if !q.isEmpty && items.isEmpty {
                VStack {
                    Spacer()
                    SearchEmpty_View()
                        .padding(.bottom, -125)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 74) }

            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(items) { item in
                            MenuListRow(
                                model: item,
                                onToggleBookmark: { vm.toggleBookmark(id: item.id) }
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
        let q = searchVM.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return vm.cards }
        return vm.cards.filter {
            $0.title.localizedCaseInsensitiveContains(q) ||
            $0.subtitle.localizedCaseInsensitiveContains(q) ||
            $0.lines.joined(separator: " ").localizedCaseInsensitiveContains(q)
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

    func presentToast(_ message: String) {
        toastMessage = message
        withAnimation(.easeOut(duration: 0.2)) {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeIn(duration: 0.2)) {
                showToast = false
            }
        }
    }
}

// 토스트 메시지 뷰
private struct ToastView: View {
    let message: String
    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.gray.opacity(0.85))
            .clipShape(Capsule())
            .shadow(radius: 6, y: 3)
    }
}

// 모달, 검색창 모서리 처리
private struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        ).cgPath)
    }
}

#Preview("Mainpage_View") {
    NavigationStack { Mainpage_View() }
}
