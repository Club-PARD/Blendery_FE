//
//  SessionManager.swift
//  Blendery
//
//  Created by 박영언 on 1/8/26.
//

import Foundation

final class SessionManager {

    static let shared = SessionManager()
    private init() {}

    private let userIdKey = "currentUserId"

    var currentUserId: String? {
        get {
            UserDefaults.standard.string(forKey: userIdKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userIdKey)
        }
    }

    func logout() {
        currentUserId = nil
    }
}
