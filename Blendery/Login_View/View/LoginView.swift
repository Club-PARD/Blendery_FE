//
//  login view.swift
//  Blendary
//
//  Created by 박성준 on 12/24/25.
//

import SwiftUI

struct LoginView: View {
    var onLoginSuccess: (() -> Void)?

    // ✅ 화면 전체에서 VM 1개만 사용
    @StateObject private var vm = LoginViewModel()

    var body: some View {
        VStack(spacing: 0) {

            // ✅ 같은 vm을 주입
            Login_ID_PW(viewModel: vm)

            Login_AutoLogin()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 16)

            // ✅ 같은 vm을 주입
            Login_Button(viewModel: vm)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 50)
        
        .onChange(of: vm.isLoggedIn) { loggedIn in
            if loggedIn {
                onLoginSuccess?()
            }
        }
    }
}

