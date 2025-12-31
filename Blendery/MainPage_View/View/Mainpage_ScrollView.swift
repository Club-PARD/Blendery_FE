//
//  Mainpage_ScrollView.swift
//  Blendery
//
//  Created by 박성준 on 12/31/25.
//

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
    @ObservedObject var vm: MainpageViewModel

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

    var favoriteMasonryView: some View {
        let columns = vm.distributeMasonry(items: vm.favoriteItems, heights: measuredHeights)

        return ScrollView {
            HStack(spacing: 17) {

                VStack(spacing: 17) {
                    ForEach(columns.left) { item in
                        MenuCardView(
                            model: item,
                            onToggleBookmark: { vm.toggleBookmark(id: item.id) }
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
                            onToggleBookmark: { vm.toggleBookmark(id: item.id) }
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
    
    @ViewBuilder
    var normalListView: some View {
        let items = vm.normalItems(for: selectedCategory)
        
        if selectedCategory == "시즌메뉴" {
            SeasonCarouselView(items: items)
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
            }
        }
    }
}

// MARK: - 카드(즐겨찾기 탭에서만)
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

// MARK: - 리스트 Row(검색 오버레이에서도 쓰니까 공개 유지)
struct MenuListRow: View {
    let model: MenuCardModel
    let onToggleBookmark: () -> Void

    var body: some View {
        Button(action: {
            // TODO: 상세화면 이동 등
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .background(Color.white)
        }
        .buttonStyle(.plain)
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
