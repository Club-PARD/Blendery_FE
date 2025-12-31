//
//  UserProfile.swift
//  Blendery
//
//  Created by 박영언 on 12/29/25.
//

import Foundation

struct UserProfile: Decodable {
    var name: String
    let role: String
    let joinedAt: String
    let phone: String
    let email: String
}
