//
//  SeasonCarouselView.swift
//  Blendery
//
//  Created by 박성준 on 12/31/25.
//

import SwiftUI
import UIKit

struct SeasonCarouselView: View {
    let items: [MenuCardModel]

    private let cardWidth: CGFloat = 248
    private let cardHeight: CGFloat = 340
    private let spacing: CGFloat = 16
    private let topOffset: CGFloat = 100

    // ✅ 3배로 복제해서 보여줄 아이템
    private var loopItems: [LoopItem] {
        guard !items.isEmpty else { return [] }
        return (0..<3).flatMap { copy in
            items.map { LoopItem(copy: copy, item: $0) }
        }
    }

    @State private var focusedID: String?   // "copy-uuid"

    var body: some View {
        GeometryReader { outer in
            let sideMargin = max((outer.size.width - cardWidth) / 2, 0)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: spacing) {
                    ForEach(loopItems) { loop in
                        GeometryReader { geo in
                            let scale = scaleForCard(geo: geo, outer: outer)

                            SeasonCard(item: loop.item)
                                .frame(width: cardWidth, height: cardHeight)
                                .scaleEffect(scale)
                                .animation(.easeOut(duration: 0.18), value: scale)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        focusedID = loop.id
                                    }
                                }
                        }
                        .frame(width: cardWidth, height: cardHeight)
                        .id(loop.id)
                    }
                }
                .scrollTargetLayout()
                .padding(.top, topOffset)
                .padding(.bottom, 18)
            }
            .contentMargins(.horizontal, sideMargin, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .scrollPosition(id: $focusedID, anchor: .center)

            //  “끝으로 가면” 같은 메뉴를 가운데(copy=1)로 순간이동
            .onChange(of: focusedID) { newValue in
                guard let newValue,
                      let parsed = LoopItem.parse(id: newValue) else { return }

                // copy 0 또는 2에 도달하면 copy 1로 점프
                if parsed.copy == 0 || parsed.copy == 2 {
                    let jumpID = LoopItem.makeID(copy: 1, originalID: parsed.originalID)

                    //  애니메이션 없이 점프해야 "무한" 느낌이 자연스러움
                    var t = Transaction()
                    t.animation = nil
                    withTransaction(t) {
                        focusedID = jumpID
                    }
                }
            }
        }
        .frame(height: cardHeight + topOffset + 18)
        .onAppear {
            //  가운데 세트(copy=1)의 첫 아이템으로 시작
            if focusedID == nil, let first = items.first {
                focusedID = LoopItem.makeID(copy: 1, originalID: first.id)
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

private struct SeasonCard: View {
    let item: MenuCardModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)

            VStack(spacing: 12) {
                imageView
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(item.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .padding(14)

            Text("시즌")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(red: 0.32, green: 0.32, blue: 0.32))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 999)
                        .stroke(Color.blue.opacity(0.8), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 999))
                .padding(12)
        }
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
    }

    private var imageView: some View {
        let name = item.title
        if UIImage(named: name) != nil {
            return AnyView(
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
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
