//
//  UserAPIService.swift
//  Blendery
//
//  Created by 박영언 on 12/29/25.
//

import Foundation

final class UserService {
    func fetchProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        let url = URL(string: "https://api.yourserver.com/user/me")!
        let token = "ACCESS_TOKEN" // 🔐 Keychain에서 가져오게 변경

        APIClient.shared.request(
            url: url,
            token: token,
            completion: completion
        )
    }
}
