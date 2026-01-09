//
//  MemberResponse.swift
//  Blendery
//
//  Created by 박성준 on 1/9/26.
//

struct MemberCafesResponse: Decodable {
    let cafes: [Cafe]
}


struct Cafe: Decodable, Identifiable {
    let cafeId: String
    let cafeName: String

    var id: String { cafeId }
    
    enum CodingKeys: String, CodingKey {
        case cafeId
        case cafeName = "CafeName"
    }
}
