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

            // ✅ 같은 vm을 주입
            Login_Button(viewModel: vm, onLoginSuccess: onLoginSuccess)
                .padding(.top, 18)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 50)
        .offset(y: -16)
        .onChange(of: vm.didLogin) { success in
            if success {
                onLoginSuccess?()
            }
        }

    }
}

