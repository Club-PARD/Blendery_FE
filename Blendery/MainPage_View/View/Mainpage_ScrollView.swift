import SwiftUI
import UIKit

private struct CardHeightKey: PreferenceKey {
    static var defaultValue: [UUID: CGFloat] = [:]
    static func reduce(value: inout [UUID: CGFloat], nextValue: () -> [UUID: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct Mainpage_ScrollView: View {
    let selectedCategory: String

    // ✅ 부모(Mainpage_View)에서 들고 내려오는 즐찾 상태
    @Binding var cards: [MenuCardModel]

    @State private var measuredHeights: [UUID: CGFloat] = [:]

    var body: some View {
        if selectedCategory == "즐겨찾기" {
            favoriteMasonryView
        } else {
            normalListView
        }
    }
}

// MARK: - FAVORITE: 카드(2열 masonry)
private extension Mainpage_ScrollView {
    var favoriteItems: [MenuCardModel] {
        cards.filter { $0.isBookmarked }
    }

    var favoriteMasonryView: some View {
        let columns = distributeMasonry(items: favoriteItems, heights: measuredHeights)

        return ScrollView {
            HStack(spacing: 17) {
                VStack(spacing: 17) {
                    ForEach(columns.left) { item in
                        MenuCardView(
                            model: item,
                            onToggleBookmark: { toggleBookmark(id: item.id) }
                        )
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: CardHeightKey.self,
                                    value: [item.id: geo.size.height]
                                )
                            }
                        )
                    }
                }

                VStack(spacing: 17) {
                    ForEach(columns.right) { item in
                        MenuCardView(
                            model: item,
                            onToggleBookmark: { toggleBookmark(id: item.id) }
                        )
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: CardHeightKey.self,
                                    value: [item.id: geo.size.height]
                                )
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 17)
            .padding(.top, 17)
        }
        .onPreferenceChange(CardHeightKey.self) { new in
            if new != measuredHeights { measuredHeights = new }
        }
    }
}

// MARK: - NORMAL: 리스트(세로로 쭉)
private extension Mainpage_ScrollView {
    var normalItems: [MenuCardModel] {
        // ✅ 즐겨찾기 제외 카테고리는 해당 카테고리만
        cards.filter { $0.category == selectedCategory }
    }

    var normalListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(normalItems) { item in
                    MenuListRow(
                        model: item,
                        onToggleBookmark: { toggleBookmark(id: item.id) }
                    )
                }
            }
            .padding(.top, 0) //  패딩 제거
        }
    }
}

// MARK: - 로직(토글/배치)
private extension Mainpage_ScrollView {
    func toggleBookmark(id: UUID) {
        guard let idx = cards.firstIndex(where: { $0.id == id }) else { return }
        cards[idx].isBookmarked.toggle()
        //  즐겨찾기 탭에서 해제하면 즉시 사라짐
    }

    func distributeMasonry(
        items: [MenuCardModel],
        heights: [UUID: CGFloat]
    ) -> (left: [MenuCardModel], right: [MenuCardModel]) {

        var left: [MenuCardModel] = []
        var right: [MenuCardModel] = []
        var leftH: CGFloat = 0
        var rightH: CGFloat = 0

        for item in items {
            let h = heights[item.id] ?? 200
            if leftH <= rightH {
                left.append(item)
                leftH += h + 17
            } else {
                right.append(item)
                rightH += h + 17
            }
        }
        return (left, right)
    }
}

// MARK: - 카드(즐겨찾기 탭에서만 사용)
private struct MenuCardView: View {
    let model: MenuCardModel
    let onToggleBookmark: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    ForEach(model.tags, id: \.self) { t in
                        Text(t)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(red: 0.71, green: 0.71, blue: 0.71).opacity(0.25))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    Spacer()
                }

                Text(model.title)
                    .font(.system(size: 18, weight: .bold))

                Text(model.subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 3) {
                    ForEach(model.lines, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(14)

            // ✅ 즐찾 아이콘 로직 정상화 (true면 '켜짐' 이미지)
            Button(action: onToggleBookmark) {
                Image(model.isBookmarked ? "즐찾아이콘" : "즐찾끔")
                    .resizable()
                    .frame(width: 14, height: 17)
                    .padding(12)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - 리스트 Row(즐겨찾기 제외 카테고리)
struct MenuListRow: View {
    let model: MenuCardModel
    let onToggleBookmark: () -> Void

    var body: some View {
        Button(action: {
            // ✅ 일단 클릭 가능하게만 (원하면 여기서 상세화면 이동)
            // print("tap:", model.title)
        }) {
            HStack(spacing: 12) {

                rowImage
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(model.category)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)

                    Text(model.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            // ✅ “가로 끝까지 덮게” 핵심
            .frame(maxWidth: .infinity, alignment: .leading)

            // ✅ 내부 여백도 원하면 0까지 가능
            // 완전 패딩 0이면 너무 붙어서 보통은 최소만 둠
            .padding(.horizontal, 0)
            .padding(.vertical, 12)

            // ✅ 테두리/카드 느낌 제거: 그냥 흰 바탕
            .background(Color.white)
        }
        .buttonStyle(.plain)

        // ✅ 항목 사이 얇은 구분선(원하면 유지/삭제 가능)
    }

    private var rowImage: some View {
        let name = model.title
        if UIImage(named: name) != nil {
            return AnyView(
                Image(name)
                    .resizable()
                    .scaledToFill()
            )
        } else {
            return AnyView(
                ZStack {
                    Color(red: 0.95, green: 0.95, blue: 0.95)
                    Image(systemName: "cup.and.saucer.fill")
                        .foregroundColor(.gray)
                }
            )
        }
    }
}

