//
//  SeasonCarouselView.swift
//  Blendery
//
//  시즌 메뉴 캐러셀 (✅ 목데이터 + 에셋 이미지 전용)
//

import SwiftUI
import UIKit

struct SeasonCarouselView: View {

    let items: [MenuCardModel]
    var onSelectMenu: (MenuCardModel) -> Void = { _ in }
    var onToggleBookmark: (UUID) -> Void = { _ in }

    private let cardWidth: CGFloat = 275
    private let cardHeight: CGFloat = 370
    private let spacing: CGFloat = 16
    private let topOffset: CGFloat = 80
    private let extraCenterScale: CGFloat = 0.06
    private var maxScale: CGFloat { 1.0 + extraCenterScale }

    private var loopItems: [LoopItem] {
        guard !items.isEmpty else { return [] }
        return (0..<5).flatMap { copy in
            items.map { LoopItem(copy: copy, item: $0) }
        }
    }

    @State private var focusedID: String?
    @State private var isJumping = false

    private var currentIndex: Int {
        guard let focusedID,
              let parsed = LoopItem.parse(id: focusedID) else { return 0 }
        return items.firstIndex(where: { $0.id == parsed.originalID }) ?? 0
    }

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { outer in
                let sideMargin = max((outer.size.width - cardWidth) / 2, 0)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: spacing) {
                        ForEach(loopItems) { loop in
                            GeometryReader { geo in
                                let baseScale = scaleForCard(geo: geo, outer: outer)
                                let isCenter = (focusedID == loop.id)
                                let xScale = baseScale * (isCenter ? 1.1 : 1.00)
                                let yScale = baseScale * (isCenter ? 1.15 : 1.00)

                                SeasonCard(
                                    item: loop.item,
                                    onToggleBookmark: { onToggleBookmark(loop.item.id) }
                                )
                                .frame(width: cardWidth, height: cardHeight)
                                .scaleEffect(x: xScale, y: yScale)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    let wasCentered = (focusedID == loop.id)

                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        focusedID = loop.id
                                    }

                                    if wasCentered {
                                        onSelectMenu(loop.item)
                                    }
                                }
                            }
                            .frame(width: cardWidth, height: cardHeight)
                            .id(loop.id)
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.top, topOffset)
                    .padding(.bottom, (cardHeight * extraCenterScale / 2) + 10)
                }
                .contentMargins(.horizontal, sideMargin, for: .scrollContent)
                .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                .scrollPosition(id: $focusedID, anchor: .center)
                .onChange(of: focusedID) { newValue in
                    guard let newValue,
                          let parsed = LoopItem.parse(id: newValue) else { return }
                    if parsed.copy == 1 || parsed.copy == 3 {
                        jumpToCenter(originalID: parsed.originalID)
                    }
                }
            }
            .frame(height: cardHeight * maxScale + topOffset + 16)

            indicatorView
                .padding(.bottom, 14)
        }
        .background(Color.clear)
        .onAppear {
            if focusedID == nil, let first = items.first {
                let startID = LoopItem.makeID(copy: 2, originalID: first.id)
                var t = Transaction()
                t.animation = nil
                t.disablesAnimations = true
                withTransaction(t) { focusedID = startID }
            }
        }
    }

    private func jumpToCenter(originalID: UUID) {
        guard !isJumping else { return }
        isJumping = true

        let jumpID = LoopItem.makeID(copy: 2, originalID: originalID)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            var t = Transaction()
            t.animation = nil
            t.disablesAnimations = true
            withTransaction(t) { focusedID = jumpID }

            DispatchQueue.main.async {
                isJumping = false
            }
        }
    }

    private func scaleForCard(geo: GeometryProxy, outer: GeometryProxy) -> CGFloat {
        let centerX = outer.size.width / 2
        let cardMidX = geo.frame(in: .scrollView(axis: .horizontal)).midX
        let distance = abs(cardMidX - centerX)

        let maxDistance = outer.size.width / 2
        let progress = min(distance / maxDistance, 1)

        return 1.0 - (progress * 0.12)
    }

    private var indicatorView: some View {
        HStack(spacing: 8) {
            ForEach(items.indices, id: \.self) { idx in
                Circle()
                    .fill(idx == currentIndex ? Color(red: 0.11, green: 0.25, blue: 0.55) : Color.gray.opacity(0.35))
                    .frame(width: 9, height: 9)
            }
        }
        .padding(.vertical, 20)
    }
}

private struct LoopItem: Identifiable {
    let copy: Int
    let item: MenuCardModel

    var id: String { "\(copy)-\(item.id.uuidString)" }

    static func makeID(copy: Int, originalID: UUID) -> String {
        "\(copy)-\(originalID.uuidString)"
    }

    static func parse(id: String) -> (copy: Int, originalID: UUID)? {
        let parts = id.split(separator: "-", maxSplits: 1).map(String.init)
        guard parts.count == 2, let c = Int(parts[0]), let uuid = UUID(uuidString: parts[1]) else { return nil }
        return (c, uuid)
    }
}

// ===============================
//  카드 UI
// ===============================
private struct SeasonCard: View {

    let item: MenuCardModel
    let onToggleBookmark: () -> Void

    private let imageHeight: CGFloat = 200 // ✅ 사진 크기 줄이기(원하면 더 낮춰)

    var body: some View {
        ZStack(alignment: .topTrailing) {

            VStack(spacing: 0) {

                imageView
                    .frame(height: imageHeight)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .padding(.top, 60)

                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {

                        Text(item.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .lineLimit(1)

                        // ✅ subtitle 옆에 텍스트 하나 더
                        // - subtitle: 온도 텍스트(예: HOT·ICED)
                        // - extra: 카테고리 코드(원하면 다른 텍스트로 바꾸면 됨)
                        HStack(spacing: 6) {
                            
                            Text("· \(item.category)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.gray.opacity(0.65))
                                .lineLimit(1)
                            
                            Text(item.subtitle)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                                .lineLimit(1)

                        }
                    }

                    Spacer()

                    Button(action: onToggleBookmark) {
                        Image(item.isBookmarked ? "즐찾아이콘" : "즐찾끔")
                            .resizable()
                            .frame(width: 14, height: 17)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
            )

            Text("NEW")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(red: 0.14, green: 0.24, blue: 0.51))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .padding(.top, 28)
                .padding(.trailing, 24)
        }
    }

    private var imageView: some View {

        // ✅ 시즌은 무조건 에셋만 사용
        // - imageName 있으면 imageName
        // - 없으면 title로 에셋 탐색
        let assetName = item.imageName ?? item.title

        if UIImage(named: assetName) != nil {
            return AnyView(
                Image(assetName)
                    .resizable()
                    .scaledToFit()
            )
        } else {
            return AnyView(
                ZStack {
                    Color.white
                    Image("loading")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 125, height: 125)
                }
            )
        }
    }
}
