//
//  Mainpage_FavoriteListView.swift
//  Blendery
//
//  즐겨찾기 리스트 뷰
//

import SwiftUI
import UIKit

private struct CardHeightKey: PreferenceKey {

    // UI 레이아웃 측정값 저장용
    static var defaultValue: [UUID: CGFloat] = [:]

    static func reduce(value: inout [UUID: CGFloat], nextValue: () -> [UUID: CGFloat]) {
        // UI 레이아웃 계산 로직
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct Mainpage_FavoriteListView: View {

    @ObservedObject var vm: MainpageViewModel
    var onSelectMenu: (MenuCardModel) -> Void = { _ in }

    @State private var measuredHeights: [UUID: CGFloat] = [:]

    var body: some View {

        // ✅ 즐겨찾기 탭에서는 favoriteCards 사용
        let columns = vm.distributeMasonry(
            items: vm.favoriteCards,
            heights: measuredHeights
        )

        ScrollView {

            // ⭐️ Empty State 처리 (중요)
            if vm.favoriteCards.isEmpty {
                VStack(spacing: 12) {
                    Text("즐겨찾기한 레시피가 없습니다")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)

                    Text("하트를 눌러 레시피를 저장해보세요")
                        .font(.system(size: 13))
                        .foregroundColor(.gray.opacity(0.8))
                }
                .frame(maxWidth: .infinity, minHeight: 300)
            } else {

                HStack(spacing: 17) {

                    VStack(spacing: 17) {
                        ForEach(columns.left) { item in
                            menuCard(item)
                        }
                    }

                    VStack(spacing: 17) {
                        ForEach(columns.right) { item in
                            menuCard(item)
                        }
                    }
                }
                .padding(.horizontal, 17)
                .padding(.top, 17)
            }
        }
        .onPreferenceChange(CardHeightKey.self) { new in
            if new != measuredHeights {
                measuredHeights = new
            }
        }
        .onAppear {
            print("⭐️ FavoriteListView onAppear favorites:", vm.favoriteCards.count)

            let c = vm.distributeMasonry(items: vm.favoriteCards, heights: measuredHeights)
            print("⭐️ columns left:", c.left.count, "right:", c.right.count)
        }
        .onChange(of: vm.favoriteCards) { newValue in
            print("⭐️ FavoriteCards changed:", newValue.count)

            let c = vm.distributeMasonry(items: newValue, heights: measuredHeights)
            print("⭐️ columns left:", c.left.count, "right:", c.right.count)
        }
    }

    // MARK: - Card View Builder
    @ViewBuilder
    private func menuCard(_ item: MenuCardModel) -> some View {
        MenuCardView(
            model: item,
            onToggleBookmark: { vm.toggleBookmarkFromMain(id: item.id) },
            onSelect: { onSelectMenu(item) }
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


// 즐겨찾기 카드 뷰
private struct MenuCardView: View {

    // 서버 데이터?
    // 메뉴 한 개의 표시 데이터
    let model: MenuCardModel

    // 서버 호출?
    // 즐겨찾기 토글 트리거
    let onToggleBookmark: () -> Void

    // 화면 이동용 이벤트
    let onSelect: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .contentShape(Rectangle())
                .onTapGesture { onSelect() }   // ✅ 카드 탭

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    ForEach(model.tags, id: \.self) { t in
                        Text(t)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.25))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    Spacer()
                }

                Text(model.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)

                Text(model.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 3) {
                    ForEach(model.lines, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(14)

            // ✅ 북마크 버튼 (이제 살아남)
            Button(action: onToggleBookmark) {
                Image(systemName: model.isBookmarked ? "bookmark.fill" : "bookmark")
                    .resizable()
                    .frame(width: 14, height: 17)
                    .padding(12)
                    .foregroundColor(.red)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}
