//
//  Mainpage_FavoriteListView.swift.swift
//  Blendery
//
//  Created by 박성준 on 1/3/26.
//

//
//  Mainpage_FavoriteListView.swift
//  Blendery
//

import SwiftUI
import UIKit

private struct CardHeightKey: PreferenceKey {
    static var defaultValue: [UUID: CGFloat] = [:]
    static func reduce(value: inout [UUID: CGFloat], nextValue: () -> [UUID: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct Mainpage_FavoriteListView: View {
    @ObservedObject var vm: MainpageViewModel
    var onSelectMenu: (MenuCardModel) -> Void = { _ in }

    @State private var measuredHeights: [UUID: CGFloat] = [:]

    var body: some View {
        let columns = vm.distributeMasonry(items: vm.favoriteItems, heights: measuredHeights)

        ScrollView {
            HStack(spacing: 17) {

                VStack(spacing: 17) {
                    ForEach(columns.left) { item in
                        MenuCardView(
                            model: item,
                            onToggleBookmark: { vm.toggleBookmark(id: item.id) },
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

                VStack(spacing: 17) {
                    ForEach(columns.right) { item in
                        MenuCardView(
                            model: item,
                            onToggleBookmark: { vm.toggleBookmark(id: item.id) },
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
            }
            .padding(.horizontal, 17)
            .padding(.top, 17)
        }
        .onPreferenceChange(CardHeightKey.self) { new in
            if new != measuredHeights { measuredHeights = new }
        }
    }
}

// 즐겨찾기 카드(이 파일 안에서만 씀)
private struct MenuCardView: View {
    let model: MenuCardModel
    let onToggleBookmark: () -> Void
    let onSelect: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)

            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { onSelect() }

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
                    .foregroundColor(.black)

                Text(model.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 3) {
                    ForEach(model.lines, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(14)

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

#Preview {
    Mainpage_FavoriteListView_swift()
}
