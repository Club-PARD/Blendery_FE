import SwiftUI

private struct CategoryFrameKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct Mainpage_TopMenu: View {
    let onTapStoreButton: () -> Void
    @Binding var selectedCategory: String
    @ObservedObject var vm: TopMenuViewModel

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
            .padding(.top, 20)
            .buttonStyle(.plain)

            HStack {
                Text("Blendery")
                    .font(.system(size: 34, weight: .bold))
                Spacer()

                Button(action: {}) {
                    Image("사람")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 26)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(vm.categories, id: \.self) { category in
                        let isSelected = (selectedCategory == category)

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCategory = category
                            }
                        } label: {
                            Text(category)
                                .font(.system(size: 15, weight: isSelected ? .bold : .regular))
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                                .padding(.horizontal, 14)
                                .frame(height: 33)
                                .foregroundColor(vm.textColor(for: category))
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
                vm.categoryFrames = frames
            }
            .overlay(alignment: .bottomLeading) {
                GeometryReader { _ in
                    if let f = vm.categoryFrames[selectedCategory] {
                        Rectangle()
                            .fill(vm.indicatorColor(for: selectedCategory))
                            .frame(width: f.width, height: 2)
                            .offset(x: f.minX, y: 0)
                            .animation(.easeInOut(duration: 0.2), value: selectedCategory)
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
        selectedCategory: .constant("즐겨찾기"),
        vm: TopMenuViewModel(categories: ["즐겨찾기", "커피", "논커피", "아이스크림", "에이드"])
    )
}
