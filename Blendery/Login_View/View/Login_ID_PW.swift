//
//  Login_ID:PW.swift
//  Blendery
//
//  Created by 박성준 on 12/25/25.
//

import SwiftUI

struct Login_ID_PW: View {

    // 상태/서버 공통 변수
    // - LoginView에서 만든 LoginViewModel을 주입 받아서 공유
    // - 여기서는 email/password 입력값(서버로 보낼 데이터)을 저장하는 용도
    // - errorMessage는 UI에서 빨간 테두리/에러 텍스트 표시용 상태로도 사용
    @ObservedObject var viewModel: LoginViewModel

    // 상태 변수
    // - 비밀번호를 보이게/가리게 하는 UI 상태
    @State private var isPasswordVisible: Bool = false

    var body: some View {

        VStack() {
            // ID
            ZStack(alignment: .leading) {

                // UI 상태 반영
                // - email이 비어있을 때만 placeholder(Text "ID")를 보여줌
                if viewModel.email.isEmpty {
                    Text("ID")
                        .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                        .padding(.leading, 20)
                        .font(.system(size: 18))
                }

                // [서버 요청 데이터 바인딩]
                // - text: $viewModel.email → 사용자가 입력하는 값이 viewModel.email에 실시간 저장됨
                // - login() 호출 시 LoginRequest(email:password:)에 들어갈 값
                TextField("", text: $viewModel.email)
                    .padding(.horizontal, 20)
                    .frame(height: 45)
                    .foregroundColor(.white)
                    .accentColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .background(Color(red: 0.15, green: 0.15, blue: 0.15))
            .cornerRadius(30)
            .frame(width: 310, height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color(red: 0.15, green: 0.15, blue: 0.15), lineWidth: 1)
            )
        }
        .padding(.bottom, 8)

        // 비번
        VStack() {
            ZStack(alignment: .leading) {

                // UI 상태 반영
                // - password가 비어있을 때만 placeholder(Text "Password")를 보여줌
                if viewModel.password.isEmpty {
                    Text("Password")
                        .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                        .padding(.leading, 20)
                        .font(.system(size: 18))
                }

                HStack {

                    // 서버 요청 데이터 바인딩
                    // - text: $viewModel.password → 사용자가 입력하는 값이 viewModel.password에 실시간 저장됨
                    // - login() 호출 시 LoginRequest(email:password:)에 들어갈 값
                    //
                    // UI 상태 반영
                    // - isPasswordVisible에 따라 TextField(보이기) / SecureField(가리기) 토글
                    if isPasswordVisible {
                        TextField("", text: $viewModel.password)
                            .foregroundColor(.white)
                            .accentColor(.white)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("", text: $viewModel.password)
                            .foregroundColor(.white)
                            .accentColor(.white)
                    }

                    // 상태 변경
                    // - 비밀번호 표시/숨김 토글
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: 45)
            }

            .background(Color(red: 0.15, green: 0.15, blue: 0.15))
            .cornerRadius(30)
            .frame(width: 310, height: 45)

            // - errorMessage가 있으면 빨간 테두리 errorMessage가 없으면 기본 테두리
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(viewModel.errorMessage != nil ? Color.red : Color(red: 0.15, green: 0.15, blue: 0.15), lineWidth: 1)
            )

            // - viewModel.errorMessage는 로그인 실패 시(LoginViewModel.login() catch) 세팅되는 UI 상태
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .transition(.opacity)
                    .animation(.easeInOut, value: viewModel.errorMessage)
            }
        }
    }
}

#Preview {
    Login_ID_PW(viewModel: LoginViewModel())
}
