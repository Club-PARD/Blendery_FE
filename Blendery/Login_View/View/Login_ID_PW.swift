//
//  Login_ID:PW.swift
//  Blendery
//
//  Created by 박성준 on 12/25/25.
//

import SwiftUI

struct Login_ID_PW: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        VStack() {
            ZStack(alignment: .leading) {
                if viewModel.email.isEmpty {
                    Text("ID")
                        .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                        .padding(.leading, 20) // 위치 미세 조정
                        .font(.system(size: 18))
                }
                
                TextField("", text: $viewModel.email)
                    .padding(.horizontal, 20) // ✨ 상하 패딩 제거, 좌우만 줌
                    .frame(height: 45) // 텍스트필드 자체 높이 확보
                    .foregroundColor(.white)
                    .accentColor(.white) // ✨ 커서 색상 흰색으로
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .background(Color(red: 0.15, green: 0.15, blue: 0.15))
            .cornerRadius(30)
            .frame(width: 310, height: 45)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color(red: 0.15, green: 0.15, blue: 0.15), lineWidth: 1)
            )
        }
        .padding(.bottom, 8)
        
        // ─── [수정됨] 비밀번호 입력 ───
        VStack() {
            ZStack(alignment: .leading) {
                if viewModel.password.isEmpty {
                    Text("Password")
                        .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                        .padding(.leading, 20)
                        .font(.system(size: 18))
                }
                
                HStack {
                    if isPasswordVisible {
                        TextField("", text: $viewModel.password)
                            .foregroundColor(.white)
                            .accentColor(.white) // 커서 흰색
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("", text: $viewModel.password)
                            .foregroundColor(.white)
                            .accentColor(.white) // 커서 흰색
                    }
                    
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
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(viewModel.errorMessage != nil ? Color.red : Color(red: 0.15, green: 0.15, blue: 0.15), lineWidth: 1)
            )
            
            // 에러 메시지
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
    Login_ID_PW()
}
