////
////  temp_Data.swift
////  Blendery
////
////  Created by 박성준 on 12/28/25.
////
//
import Foundation

let categories: [String] = [
    "즐겨찾기",
    "시즌메뉴",
    "커피",
    "논커피",
    "에이드",
    "과일주스",
    "블렌디드",
    "티",
    "아이스크림"
]

struct MenuCardModel: Identifiable {
    let id = UUID()
    let category: String        //  추가: 필터링 기준
    let tags: [String]
    let title: String
    let subtitle: String
    let lines: [String]
    var isBookmarked: Bool
}

let menuCardsMock: [MenuCardModel] = [
    //  true 5개만 유지
    MenuCardModel(
        category: "커피",
        tags: ["ICE", "EX"],
        title: "민트 모카",
        subtitle: "에스프레소 3샷",
        lines: ["민트초코파우더 3스푼", "혼합 + 스팀우유 윗선", "혼합 + 얼음 9부", "휘핑크림 + 민트초콜릿 파우더 토핑"],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "커피",
        tags: ["ICE", "EX"],
        title: "민트 모카",
        subtitle: "에스프레소 3샷",
        lines: [
            "민트초코 파우더 3스푼",
            "초코 소스 2펌프",
            "에스프레소 3샷 추출",
            "혼합 + 스팀우유 윗선",
            "컵 벽면 초코 드리즐",
            "혼합 + 얼음 9부",
            "휘핑크림 듬뿍",
            "민트초콜릿 파우더 토핑",
            "초코칩 소량 추가(선택)",
            "뚜껑 닫고 완성"
        ],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "논커피",
        tags: ["EX"],
        title: "초코 라떼",
        subtitle: "논커피",
        lines: ["초코 소스 3펌프", "스팀우유 윗선", "휘핑크림 토핑(선택)"],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "에이드",
        tags: ["ICE"],
        title: "자몽 에이드",
        subtitle: "에이드",
        lines: ["자몽 베이스 3펌프", "탄산수 윗선", "얼음 9부"],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "과일주스",
        tags: ["ICE"],
        title: "딸기 주스",
        subtitle: "과일주스",
        lines: ["딸기 베이스", "물/우유 선택", "얼음 9부(선택)"],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "블렌디드",
        tags: ["ICE"],
        title: "그린티 블렌디드",
        subtitle: "블렌디드",
        lines: ["파우더 3스푼", "우유 윗선", "블렌딩", "휘핑 토핑(선택)"],
        isBookmarked: false
    ),
    MenuCardModel(
        category: "에이드",
        tags: ["ICE"],
        title: "자몽 에이드",
        subtitle: "에이드",
        lines: [
            "자몽 베이스 3펌프",
            "레몬 베이스 1펌프",
            "컵에 얼음 9부 채우기",
            "탄산수 절반 붓기",
            "자몽 베이스 투입",
            "탄산수 윗선까지 추가",
            "천천히 저어 탄산 유지",
            "자몽 슬라이스 토핑(선택)",
            "빨대 제공"
        ],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "시즌메뉴",
        tags: ["ICE"],
        title: "시즌 딸기라떼",
        subtitle: "시즌메뉴",
        lines: ["딸기 베이스", "우유 윗선", "얼음 9부"],
        isBookmarked: true
    ),

    MenuCardModel(
        category: "커피",
        tags: ["ICE"],
        title: "카라멜 마끼아또",
        subtitle: "에스프레소 2샷",
        lines: ["카라멜 시럽 2펌프", "우유 윗선", "얼음 9부"],
        isBookmarked: false
    ),
    MenuCardModel(
        category: "커피",
        tags: ["EX"],
        title: "아메리카노",
        subtitle: "에스프레소 2샷",
        lines: ["에스프레소 추출", "뜨거운 물 윗선"],
        isBookmarked: false
    ),
    MenuCardModel(
        category: "에이드",
        tags: ["ICE"],
        title: "자몽 에이드",
        subtitle: "에이드",
        lines: [
            "자몽 베이스 3펌프",
            "레몬 베이스 1펌프",
            "컵에 얼음 9부 채우기",
            "탄산수 절반 붓기",
            "자몽 베이스 투입",
            "탄산수 윗선까지 추가",
            "천천히 저어 탄산 유지",
            "자몽 슬라이스 토핑(선택)",
            "빨대 제공"
        ],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "과일주스",
        tags: ["ICE"],
        title: "딸기 주스",
        subtitle: "과일주스",
        lines: [
            "냉동 딸기 120g",
            "딸기 베이스 2스푼",
            "우유 또는 물 선택",
            "컵 표시선까지 액체 추가",
            "얼음 6부(선택)",
            "블렌더에 재료 투입",
            "고속 블렌딩 25초",
            "컵에 옮겨 담기",
            "딸기 조각 토핑(선택)"
        ],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "커피",
        tags: ["EX"],
        title: "카페 라떼",
        subtitle: "에스프레소 2샷",
        lines: ["스팀우유 윗선", "폼 1cm(선택)"],
        isBookmarked: true
    ),

    MenuCardModel(
        category: "논커피",
        tags: ["ICE"],
        title: "딸기 라떼",
        subtitle: "논커피",
        lines: ["딸기 베이스", "우유 윗선", "얼음 9부"],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "블렌디드",
        tags: ["ICE"],
        title: "그린티 블렌디드",
        subtitle: "블렌디드",
        lines: [
            "그린티 파우더 3스푼",
            "설탕 시럽 1펌프(선택)",
            "우유 컵 표시선까지",
            "얼음 9부",
            "블렌더에 재료 투입",
            "1단 블렌딩 10초",
            "2단 블렌딩 20초",
            "농도 확인 후 재블렌딩",
            "휘핑크림 토핑",
            "그린티 파우더 추가 토핑"
        ],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "논커피",
        tags: ["ICE"],
        title: "고구마 라떼",
        subtitle: "논커피",
        lines: ["고구마 베이스", "우유 윗선", "얼음 9부(선택)"],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "논커피",
        tags: ["EX"],
        title: "흑임자 라떼",
        subtitle: "논커피",
        lines: ["흑임자 베이스", "스팀우유 윗선", "혼합"],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "논커피",
        tags: ["ICE"],
        title: "토피넛 라떼",
        subtitle: "논커피",
        lines: ["토피넛 시럽 2펌프", "우유 윗선", "얼음 9부"],
        isBookmarked: true
    ),

    MenuCardModel(
        category: "에이드",
        tags: ["ICE"],
        title: "레몬 에이드",
        subtitle: "에이드",
        lines: ["레몬 베이스 3펌프", "탄산수 윗선", "얼음 9부"],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "에이드",
        tags: ["ICE"],
        title: "청포도 에이드",
        subtitle: "에이드",
        lines: ["청포도 베이스 3펌프", "탄산수 윗선", "얼음 9부"],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "에이드",
        tags: ["ICE"],
        title: "블루레몬 에이드",
        subtitle: "에이드",
        lines: ["블루레몬 베이스 3펌프", "탄산수 윗선", "얼음 9부"],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "에이드",
        tags: ["ICE"],
        title: "유자 에이드",
        subtitle: "에이드",
        lines: ["유자 베이스 3펌프", "탄산수 윗선", "얼음 9부"],
        isBookmarked: false
    ),

    MenuCardModel(
        category: "과일주스",
        tags: ["ICE"],
        title: "망고 주스",
        subtitle: "과일주스",
        lines: ["망고 베이스", "물/우유 선택", "얼음 9부(선택)"],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "과일주스",
        tags: ["ICE"],
        title: "바나나 주스",
        subtitle: "과일주스",
        lines: ["바나나 베이스", "우유 윗선", "블렌딩"],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "과일주스",
        tags: ["ICE"],
        title: "키위 주스",
        subtitle: "과일주스",
        lines: ["키위 베이스", "물 윗선", "얼음 9부(선택)"],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "과일주스",
        tags: ["ICE"],
        title: "오렌지 주스",
        subtitle: "과일주스",
        lines: ["오렌지 베이스", "물 윗선", "얼음 9부(선택)"],
        isBookmarked: true
    ),

    MenuCardModel(
        category: "블렌디드",
        tags: ["ICE"],
        title: "초코 블렌디드",
        subtitle: "블렌디드",
        lines: ["초코 파우더 3스푼", "우유 윗선", "블렌딩", "휘핑 토핑(선택)"],
        isBookmarked: false
    ),
    MenuCardModel(
        category: "블렌디드",
        tags: ["ICE"],
        title: "딸기 블렌디드",
        subtitle: "블렌디드",
        lines: ["딸기 베이스", "우유 윗선", "블렌딩", "휘핑 토핑(선택)"],
        isBookmarked: true
    ),
    MenuCardModel(
        category: "블렌디드",
        tags: ["ICE"],
        title: "망고 블렌디드",
        subtitle: "블렌디드",
        lines: ["망고 베이스", "우유 윗선", "블렌딩", "휘핑 토핑(선택)"],
        isBookmarked: false
    ),
    MenuCardModel(
        category: "블렌디드",
        tags: ["ICE"],
        title: "쿠키앤크림 블렌디드",
        subtitle: "블렌디드",
        lines: ["쿠키 파우더 3스푼", "우유 윗선", "블렌딩", "쿠키 토핑(선택)"],
        isBookmarked: false
    ),

    MenuCardModel(
        category: "티",
        tags: ["ICE"],
        title: "아이스 복숭아 티",
        subtitle: "티",
        lines: ["복숭아 베이스 2펌프", "물 윗선", "얼음 9부"],
        isBookmarked: false
    ),
    MenuCardModel(
        category: "티",
        tags: ["EX"],
        title: "캐모마일 티",
        subtitle: "티",
        lines: ["티백 1개", "뜨거운 물 윗선", "우려내기 3분"],
        isBookmarked: false
    ),
    MenuCardModel(
        category: "티",
        tags: ["ICE"],
        title: "아이스 자스민 티",
        subtitle: "티",
        lines: ["티백 1개", "물 윗선", "얼음 9부", "우려낸 뒤 붓기"],
        isBookmarked: false
    ),

    MenuCardModel(
        category: "시즌메뉴",
        tags: ["ICE"],
        title: "시즌 초코라떼",
        subtitle: "시즌메뉴",
        lines: ["초코 베이스", "우유 윗선", "얼음 9부(선택)"],
        isBookmarked: false
    ),
    MenuCardModel(
        category: "시즌메뉴",
        tags: ["ICE"],
        title: "시즌 유자차",
        subtitle: "시즌메뉴",
        lines: ["유자 베이스 3스푼", "뜨거운 물 윗선", "혼합"],
        isBookmarked: false
    ),
    MenuCardModel(
        category: "시즌메뉴",
        tags: ["ICE"],
        title: "시즌 고구마라떼",
        subtitle: "시즌메뉴",
        lines: ["고구마 베이스", "우유 윗선", "얼음 9부(선택)"],
        isBookmarked: false
    ),
    MenuCardModel(
        category: "시즌메뉴",
        tags: ["ICE", "EX"],
        title: "시즌 민트초코",
        subtitle: "시즌메뉴",
        lines: ["민트 파우더 3스푼", "우유 윗선", "얼음 9부(선택)", "초코칩 토핑(선택)"],
        isBookmarked: false
    )
]
