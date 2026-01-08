//
//  RootView.swift
//  Blendery
//
//  Created by 박영언 on 1/8/26.
//

import SwiftUI

struct RootView: View {

    @State private var isLoggedIn = false
    @State private var appResetID = UUID()

    var body: some View {
        NavigationStack {
            Group {
                if isLoggedIn {
                    Mainpage_View(
                        onLogout: {
                            logout()
                        }
                    )
                } else {
                    OnboardingAnimationView(
                        onLoginSuccess: {
                            isLoggedIn = true
                        }
                    )
                }
            }
        }
        .id(appResetID)
        .onAppear {
            checkAutoLogin()
        }
    }

    private func checkAutoLogin() {
        guard
            let userId = SessionManager.shared.currentUserId,
            KeychainHelper.shared.readToken(for: userId) != nil
        else {
            return
        }
        isLoggedIn = true
    }

    private func logout() {
        print("🔥 logout")

        if let userId = SessionManager.shared.currentUserId {
            KeychainHelper.shared.deleteToken(for: userId)
        }

        SessionManager.shared.currentUserId = nil
        isLoggedIn = false

        appResetID = UUID()

        print("✅ 완전 로그아웃")
    }
}

