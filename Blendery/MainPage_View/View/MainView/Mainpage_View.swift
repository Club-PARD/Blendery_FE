//
//  Mainpage_View.swift
//  Blendery
//

import SwiftUI
import UIKit

struct Mainpage_View: View {
    var onLogout: (() -> Void)? = nil
    
    // 뷰 상태 변수
    @State private var showStoreModal: Bool = false
    
    @State private var goStaffList: Bool = false
    
    // 뷰 상태 변수
    // 서버가 카테고리별 데이터를 내려주는 구조면 선택값이 서버 요청 조건이 될 수 있음
    @State private var selectedCategory: String = "즐겨찾기"
    
    // 뷰 상태 변수
    @State private var toastMessage: String = ""
    
    // 뷰 상태 변수
    @State private var toastIconName: String? = nil
    
    // 뷰 상태 변수
    @State private var showToast: Bool = false
    
    private struct RecipeNavID: Identifiable, Hashable {
        let id: UUID
    }
    @State private var selectedRecipe: RecipeNavID? = nil
    
    private var userId: String? {
        SessionManager.shared.currentUserId
    }
    
    
    // 상태 오브젝트
    // 메인 화면 데이터 소스 역할
    // 서버 연결 핵심 후보
    // 메뉴 목록 조회, 즐겨찾기 토글 저장, 로딩 상태 등이 여기로
    @StateObject private var vm = MainpageViewModel()
    
    // 상태 오브젝트
    // 검색 입력과 포커스 상태 담당
    // 서버 검색을 붙이면 여기의 text가 서버 요청 조건이 될 수 있음
    @StateObject private var searchVM = SearchBarViewModel()
    
    // 상태 오브젝트
    // 상단 카테고리 메뉴 데이터 소스
    // 보통은 로컬 상수지만 서버에서 카테고리를 내려주는 구조면 서버 데이터가 될 수도 있음
    @StateObject private var topMenuVM: TopMenuViewModel
    init(onLogout: (() -> Void)? = nil) {
        self.onLogout = onLogout
        _topMenuVM = StateObject(
            wrappedValue: TopMenuViewModel(categories: categories)
        )
    }
    
    // 뷰 포커스 상태
    // 키보드 포커스 관리
    // 서버와 무관
    @FocusState private var isSearchFieldFocused: Bool
    
    // 뷰 네비게이션 상태
    // 상세 화면으로 넘길 선택 메뉴
    // 서버 데이터일 가능성 높음
    // 선택된 MenuCardModel 자체는 서버에서 내려받은 모델일 가능성이 큼
    @State private var selectedMenu: MenuCardModel? = nil
    
    // 뷰 네비게이션 상태
    // 프로필 화면 이동 여부
    // 서버와 무관
    @State private var showProfile = false
    
    @State private var showSearchSheet = false
    
    private var searchedMenus: [MenuCardModel] {
            let q = searchVM.text.trimmingCharacters(in: .whitespacesAndNewlines)
            let base = vm.cards

            if q.isEmpty { return base }

            return base.filter {
                $0.title.localizedCaseInsensitiveContains(q) ||
                $0.subtitle.localizedCaseInsensitiveContains(q) ||
                $0.lines.joined(separator: " ").localizedCaseInsensitiveContains(q)
            }
        }
    
    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                
                Mainpage_TopMenu(
                    // 뷰 이벤트 처리
                    // 서버와 무관
                    // 다만 매장 선택을 서버로 저장하거나 불러오면 서버 요청으로 확장 가능
                    onTapStoreButton: {
                        withAnimation(.easeInOut(duration: 0.25)) { showStoreModal = true }
                    },
                    
                    // 뷰 이벤트 처리
                    // 서버와 무관
                    onTapProfileButton: {
                        showProfile = true
                    },
                    
                    onTapAdminButton: {
                        // ✅ [동작] StaffList로 이동
                        goStaffList = true
                    },
                    
                    onTapCategory: { category in
                        print("🟢 Mainpage_View received category:", category)

                        Task {
                            if category == "즐겨찾기" {
                                print("🟢 calling loadFavoritesForMyCafe")
                                await vm.loadFavoritesForMyCafe()
                            }
                        }
                    },
                    
                    // 뷰 상태 바인딩
                    // 선택된 카테고리 값 전달
                    // 서버와 직접 무관
                    // 카테고리별 서버 조회 구조라면 서버 요청 조건 역할
                    selectedCategory: $selectedCategory,
                    
                    // 화면 구성용 데이터 소스
                    // 서버와 직접 무관
                    vm: topMenuVM
                )
                .background(Color.white)
                
                TabView(selection: $selectedCategory) {
                    ForEach(topMenuVM.categories, id: \.self) { category in
//                        ScreenshotShield {
                            Mainpage_ScrollView(
                                selectedCategory: category,
                                vm: vm,
                                onSelectMenu: { menu in
                                    selectedRecipe = RecipeNavID(id: menu.id)
                                }
                            )
//                        }
                        .tag(category) // ✅ TabView selection과 연결
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never)) // ✅ 아래 점(페이지 인디케이터) 숨김
                .frame(maxWidth: .infinity, maxHeight: .infinity) // ✅ frame은 여기(TabView)에만 1번
                .onChange(of: selectedCategory) { newCategory in
                    Task {
                        if newCategory == "즐겨찾기" {
                            print("🟢 onChange -> loadFavoritesForMyCafe")
                            await vm.loadFavoritesForMyCafe()
                            return
                        }

                        guard let userId else {
                            print("⛔️ userId nil")
                            return
                        }

                        guard let serverCategory = vm.serverCategory(from: newCategory) else {
                            print("⛔️ invalid category:", newCategory)
                            return
                        }

                        print("🟢 onChange -> fetchRecipes:", serverCategory)
                        await vm.fetchRecipes(
                            franchiseId: "ac120003-9b6e-19e0-819b-6e8a08870001",
                            category: serverCategory
                        )
                    }
                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            
            // 검색 오버레이 표시 조건
            // 뷰 상태 기반
            // 서버와 무관
            if searchVM.isFocused {
                Mainpage_SearchOverlayView(
                    searchVM: searchVM,
                    focus: $isSearchFieldFocused,
                    onSelect: { recipeId in
                        selectedRecipe = RecipeNavID(id: recipeId)
                    }
                )
                .transition(.opacity)
                .zIndex(80)
            }
            
            // 스토어 선택 모달 표시 조건
            // 뷰 상태 기반
            // 서버와 무관
            if showStoreModal {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                
                // 뷰 이벤트 처리
                // 서버와 무관
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) { showStoreModal = false }
                    }
                    .zIndex(90)
                
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        
                        // UI 안전영역 처리
                        // 서버와 무관
                        
                        Color.white
                            .frame(height: geo.safeAreaInsets.top)
                        
                        StoreSelectPanel(
                            // 뷰 이벤트 처리
                            // 서버와 무관
                            // 매장 선택 값을 서버에 저장하는 구조라면 여기서 서버 호출로 확장 가능
                            onClose: {
                                withAnimation(.easeInOut(duration: 0.2)) { showStoreModal = false }
                            }
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .background(Color.white)
                    
                    // UI 모서리 처리
                    // 서버와 무관
                    .clipShape(RoundedCorner(radius: 16, corners: [.bottomLeft, .bottomRight]))
                    .transition(.move(edge: .top))
                    .ignoresSafeArea(edges: .top)
                }
                .zIndex(100)
            }
        }
        .navigationBarBackButtonHidden(true)
        
//        .onChange(of: searchVM.text) { _ in
//            Task {
//                await searchVM.search()
//            }
//        }
        
        
        // 네비게이션 처리
        // 현재는 하드코딩 데이터
        // 서버 연동 시 UserProfile이 서버 데이터가 될 수 있음
        .navigationDestination(isPresented: $showProfile) {
            ProfileView(
                profile: UserProfile(
                    name: "이지수",
                    role: "매니저",
                    joinedAt: "2010.12.25~",
                    phone: "010-7335-1790",
                    email: "l_oxo_l@handong.ac.kr"
                ),
                onLogout: onLogout
            )
        }
        
        .navigationDestination(isPresented: $goStaffList) {
            StaffList_View()
        }
        
        .navigationDestination(item: $selectedRecipe) { nav in
            if let userId {
                DetailRecipeViewByID(
                    recipeId: nav.id,
                    userId: userId
                )
            } else {
                // 로그아웃 상태에서 들어오는 걸 방어
                EmptyView()
            }
        }
        
        // 뷰 상태 업데이트
        // vm.toast 값 변화를 받아 토스트 표시
        // vm.toast가 서버 응답에 의해 세팅될 수는 있음
        .onChange(of: vm.toast) { newToast in
            guard let newToast else { return }
            presentToast(newToast)
            vm.clearToast()
        }
        
        // UI 오버레이
        // 서버와 무관
        .overlay(alignment: .bottom) {
            if showToast {
                Toastmessage_View(message: toastMessage, iconName: toastIconName)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(999)
            }
        }
        
        // 하단 검색바 영역 배치
        // 서버와 무관
        // 검색 서버 연동 시 searchVM.text가 서버 요청 조건이 됨
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
                    
                    .disabled(showStoreModal)
                    .allowsHitTesting(!showStoreModal)
                    .opacity(showStoreModal ? 0.35 : 1.0)
                    .animation(.easeInOut(duration: 0.18), value: showStoreModal)
                    
                    // 안전영역 하단 패딩 처리
                    // 서버와 무관
                    Color.clear
                        .frame(height: geo.safeAreaInsets.bottom)
                }
                .frame(maxWidth: .infinity)
                
                // UI 배경 처리
                // 서버와 무관
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

// 토스트 표시 함수
// UI 상태 변경 로직
// 서버와 무관
private extension Mainpage_View {
    func presentToast(_ data: ToastData) {
        
        // UI 상태값 세팅
        // 서버와 무관
        toastMessage = data.message
        toastIconName = data.iconName
        
        withAnimation(.easeOut(duration: 0.2)) {
            showToast = true
        }
        
        // UI 타이머로 자동 종료
        // 서버와 무관
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeIn(duration: 0.2)) {
                showToast = false
            }
        }
    }
}

// UI 모서리 Shape
// 서버와 무관
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

extension ProcessInfo {
    var isPreview: Bool {
        environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
