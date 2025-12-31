//
//  login view.swift
//  Blendary
//
//  Created by 박성준 on 12/24/25.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack(spacing: 0) {
            Login_ID_PW()

            Login_AutoLogin()
                .padding(.vertical, 16)

            Login_Button()
        }
        .frame(maxWidth: .infinity)     // ⭐️ 내부 레이아웃 폭 안정화
        .padding(.horizontal, 50)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                LoginView()
            }
        }
    }
}

