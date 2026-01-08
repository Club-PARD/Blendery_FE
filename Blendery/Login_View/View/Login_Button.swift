//
//  Login_Button.swift
//  Blendery
//
//  Created by 박성준 on 12/25/25.
//

import SwiftUI

struct Login_Button: View {

    // ✅ LoginView에서 만든 vm 공유
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        ZStack {
            Button(action: {
                // ✅ 여기서 “진짜 로그인” 실행
                viewModel.login()
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: .white)
                        )
                } else {
                    Text("로그인")
                        .fontWeight(.semibold)
                }
            }
            .frame(width: 300, height: 40)
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(30)
            .disabled(viewModel.isLoading)

            // ✅ 로그인 성공해야만 메인으로 이동
            NavigationLink(
                destination: Mainpage_View(),
                isActive: $viewModel.isLoggedIn
            ) {
                EmptyView()
            }
            .hidden()
        }
    }
}

#Preview {
    Login_Button(viewModel: LoginViewModel())
}
