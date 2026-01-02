//
//  SeasonCarouselView.swift
//  Blendery
//
//  ✅ 방법 1: 5배 복제 + 가운데(copy=2)로 유지해서 "무한 스크롤"이 자연스럽게 느껴지게
//  ✅ 탭하면 onSelectMenu로 상세로 이동 가능
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
    private let extraCenterScale: CGFloat = 0.06   // 너가 가운데에 더하는 값
    private var maxScale: CGFloat { 1.0 + extraCenterScale }

    // ✅ 5배 복제 (0,1,2,3,4) / 가운데는 copy=2
    private var loopItems: [LoopItem] {
        guard !items.isEmpty else { return [] }
        return (0..<5).flatMap { copy in
            items.map { LoopItem(copy: copy, item: $0) }
        }
    }
    
    private func isCentered(_ loopID: String) -> Bool {
        // 현재 스크롤이 맞춰진 카드(focusedID)와 탭한 카드(loopID)가 같으면 "가운데 카드"
        return focusedID == loopID
    }

    @State private var focusedID: String?       // "copy-uuid"
    @State private var isJumping = false

    // ✅ 인디케이터용 현재 인덱스
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
                                .animation(.easeOut(duration: 0.18), value: focusedID)
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

    // MARK: - Jump (중앙 copy=2로 복귀)
    private func jumpToCenter(originalID: UUID) {
        guard !isJumping else { return }
        isJumping = true

        let jumpID = LoopItem.makeID(copy: 2, originalID: originalID)

        // ✅ 스냅 애니메이션이 끝난 직후에 "무애니메이션 점프"
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

    // MARK: - Scale
    private func scaleForCard(geo: GeometryProxy, outer: GeometryProxy) -> CGFloat {
        let centerX = outer.size.width / 2
        let cardMidX = geo.frame(in: .scrollView(axis: .horizontal)).midX
        let distance = abs(cardMidX - centerX)

        let maxDistance = outer.size.width / 2
        let progress = min(distance / maxDistance, 1)

        return 1.0 - (progress * 0.12)
    }

    // MARK: - Indicator
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

// MARK: - LoopItem (원형 캐러셀용 래퍼)
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

// MARK: - Card UI
private struct SeasonCard: View {
    let item: MenuCardModel
    let onToggleBookmark: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {

            VStack(spacing: 0) {
                
                imageView
                    .frame(height: 260)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .padding(.top, 20)

                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .lineLimit(1)

                        Text(item.subtitle)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                            .lineLimit(1)
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
        let name = item.title
        if UIImage(named: name) != nil {
            return AnyView(
                Image(name)
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

#Preview("SeasonCarouselView - 시즌메뉴") {
    let demoItems: [MenuCardModel] = [
        MenuCardModel(
            category: "시즌메뉴",
            tags: ["NEW"],
            title: "아메리카노",
            subtitle: "논커피 | ICED Only",
            lines: ["진한 원두", "깔끔한 맛"],
            isBookmarked: true
        ),
        MenuCardModel(
            category: "시즌메뉴",
            tags: ["NEW"],
            title: "라떼",
            subtitle: "Milk | HOT/ICED",
            lines: ["부드러운 우유", "고소한 맛"],
            isBookmarked: false
        ),
        MenuCardModel(
            category: "시즌메뉴",
            tags: ["NEW"],
            title: "바닐라라떼",
            subtitle: "Sweet | ICED Only",
            lines: ["바닐라 향", "달콤한 맛"],
            isBookmarked: true
        ),
        MenuCardModel(
            category: "시즌메뉴",
            tags: ["NEW"],
            title: "콜드브루",
            subtitle: "Cold Brew | ICED",
            lines: ["산미 적음", "진한 향"],
            isBookmarked: false
        )
    ]

    return SeasonCarouselView(items: demoItems) { selected in
        print("✅ 선택:", selected.title)
    }
    .padding(.top, 10)
    .background(Color(red: 0.97, green: 0.97, blue: 0.97))
}
