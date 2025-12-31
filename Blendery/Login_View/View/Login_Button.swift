//
//  Login_Button.swift
//  Blendery
//
//  Created by 박성준 on 12/25/25.
//

import SwiftUI

struct Login_Button: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        Button(action: {
            viewModel.login()
        }) {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text("로그인")
                    .fontWeight(.semibold)
            }
        }
        .frame(width: 300, height: 45)
        .background(Color.white)
        .foregroundColor(.black)
        .cornerRadius(30)
        .disabled(viewModel.isLoading) // 로딩 중 버튼 비활성화
        
        
        // 테스트 계정 힌트 (개발용)
//        VStack {
//            Text("테스트 계정:")
//            Text("ID: test")
//            Text("PW: 1234")
//        }
//        .font(.footnote)
//        .foregroundColor(.white)
    }
    }

