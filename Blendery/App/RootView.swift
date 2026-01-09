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
                            print("🚨 onLoginSuccess CALLED")
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
        .onChange(of: isLoggedIn) { newValue in
            print("🧭 RootView isLoggedIn ->", newValue)
        }
    }
    

    private func checkAutoLogin() {
        let userId = SessionManager.shared.currentUserId
        let token = userId.flatMap { KeychainHelper.shared.readToken(for: $0) }

        print("🧪 autoLogin check | userId:", userId ?? "nil",
              "| token exists:", token != nil)

        guard let userId, token != nil else { return }
        isLoggedIn = true
    }

    private func logout() {
        print("🔥 logout")

        let beforeUserId = SessionManager.shared.currentUserId
        let beforeToken = beforeUserId.flatMap { KeychainHelper.shared.readToken(for: $0) }
        print("🧪 before | userId:", beforeUserId ?? "nil", "| token exists:", beforeToken != nil)

        if let userId = beforeUserId {
            KeychainHelper.shared.deleteToken(for: userId)
        }

        let afterDeleteToken = beforeUserId.flatMap { KeychainHelper.shared.readToken(for: $0) }
        print("🧪 after deleteToken | userId:", beforeUserId ?? "nil", "| token exists:", afterDeleteToken != nil)

        SessionManager.shared.currentUserId = nil
        isLoggedIn = false
        appResetID = UUID()

        print("🧪 after session nil | userId:", SessionManager.shared.currentUserId ?? "nil")
        print("✅ 완전 로그아웃")
    }

}

