//
//  Seasonmenu.swift
//  Blendery
//
//  Created by 박성준 on 1/10/26.
//

//  SeasonMenuMock.swift

import Foundation

struct SeasonMenuMockItem: Identifiable, Codable, Hashable {
    let recipeId: UUID             // ✅ 상세 페이지 서버 조회용 (반드시 서버 UUID와 매칭되어야 함)
    let imageName: String          // ✅ 에셋 이미지 이름(너가 말한대로 메뉴명과 동일하게 맞춰도 됨)
    let title: String              // ✅ 메뉴 이름
    let category: String           // ✅ 카테고리(서버 카테고리 코드 그대로)
    let temperature: String        // ✅ "HOT" / "ICE" 같은 텍스트

    var id: UUID { recipeId }

    static let items: [SeasonMenuMockItem] = [
        .init(
            recipeId: UUID(uuidString: "ac120003-9ba3-11a6-819b-a35a38dc0005")!, // ✅ 서버 UUID로 교체
            imageName: "멜팅 피스타치오",
            title: "멜팅 피스타치오",
            category: "BLENDED",
            temperature: "ICED Only"
        ),
        .init(
            recipeId: UUID(uuidString: "ac120003-9ba3-11a6-819b-a35878670004")!, // ✅ 서버 UUID로 교체
            imageName: "너티초콜릿",
            title: "너티초콜릿",
            category: "NON_COFFEE",
            temperature: "HOT·ICED"
        ),
        .init(
            recipeId: UUID(uuidString: "ac120003-9ba3-11a6-819b-a355b49e0003")!, // ✅ 서버 UUID로 교체
            imageName: "생과일 제주 감귤 주스",
            title: "생과일 제주 감귤 주스",
            category: "ADE",
            temperature: "ICED Only"
        ),
        .init(
            recipeId: UUID(uuidString: "ac120003-9ba3-11a6-819b-a35156190002")!, // ✅ 서버 UUID로 교체
            imageName: "딸기 자두 요구르트",
            title: "딸기 자두 요구르트",
            category: "BLENDED",
            temperature: "ICED Only"
        ),
        .init(
            recipeId: UUID(uuidString: "ac120003-9ba3-11a6-819b-a34e4c740001")!, // ✅ 서버 UUID로 교체
            imageName: "치즈폼 딸기라떼",
            title: "치즈폼 딸기라떼",
            category: "NON_COFFEE",
            temperature: "ICED Only"
        ),
        .init(
            recipeId: UUID(uuidString: "ac120003-9ba3-11a6-819b-a34b38930000")!, // ✅ 서버 UUID로 교체
            imageName: "딸기 감귤티",
            title: "딸기 감귤티",
            category: "TEA",
            temperature: "HOT·ICED"
        ),
    ]
}
