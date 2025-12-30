import SwiftUI

private struct CategoryFrameKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct Mainpage_TopMenu: View {
    let onTapStoreButton: () -> Void
    let categories: [String]
    @Binding var selectedCategory: String

    @State private var categoryFrames: [String: CGRect] = [:]

    // ✅ 주황색(원하는 값으로 조절)
    private let favoriteOrange = Color(red: 0.89, green: 0.19, blue: 0)

    private var favoriteKey: String {
        categories.first ?? "즐겨찾기"
    }

    var body: some View {
        VStack(spacing: 12) {

            Button(action: onTapStoreButton) {
                HStack {
                    Image("이디야 로고")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 111, height: 10)

                    Image("아래")
                        .resizable()
                        .frame(width: 13, height: 10)

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .padding(.top , 20)
            .buttonStyle(.plain)

            HStack {
                Text("Blendery")
                    .font(.system(size: 34, weight: .bold))
                Spacer()

                Button(action: {
                    // 프로필 버튼 액션
                }) {
                    Image("사람")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 26)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(categories.enumerated()), id: \.element) { idx, category in
                        let isSelected = (selectedCategory == category)
                        let isFavorite = (category == favoriteKey)
                        let itemWidth: CGFloat =
                            (idx == 0) ? 80 :
                            (category == "아이스크림") ? 80 : 63

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCategory = category
                            }
                        } label: {
                            Text(category)
                                .font(.system(size: 15, weight: isSelected ? .bold : .regular))
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)   // ✅ 글자 폭대로 커지게(… 방지)
                                .padding(.horizontal, 14)                       // ✅ 버튼 좌우 여백(= 버튼 폭)
                                .frame(height: 33)
                                .frame(minWidth: idx == 0 ? 80 : 0)             // ✅ (선택) 즐겨찾기만 최소폭 유지
                                .foregroundColor(isFavorite ? favoriteOrange : .black)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear.preference(
                                            key: CategoryFrameKey.self,
                                            value: [category: geo.frame(in: .named("CategoryScroll"))]
                                        )
                                    }
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .coordinateSpace(name: "CategoryScroll")
            .onPreferenceChange(CategoryFrameKey.self) { frames in
                self.categoryFrames = frames
            }
            .overlay(alignment: .bottomLeading) {
                GeometryReader { proxy in
                    ZStack(alignment: .bottomLeading) {

                        // ✅ 선택 인디케이터(색 규칙 적용)
                        if let f = categoryFrames[selectedCategory] {
                            let indicatorColor: Color = (selectedCategory == favoriteKey)
                                ? favoriteOrange
                                : .black

                            Rectangle()
                                .fill(indicatorColor)
                                .frame(width: f.width, height: 2)
                                .offset(x: f.minX, y: 0)
                                .animation(.easeInOut(duration: 0.2), value: selectedCategory)
                        }
                    }
                }
                .frame(height: 2)
            }
        }
    }
}

#Preview {
    Mainpage_TopMenu(
        onTapStoreButton: {},
        categories: ["즐겨찾기", "커피", "논커피", "에이드"],
        selectedCategory: .constant("즐겨찾기")
    )
}
