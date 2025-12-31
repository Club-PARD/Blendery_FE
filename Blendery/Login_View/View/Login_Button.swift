//
//  Login_Button.swift
//  Blendery
//
//  Created by 박성준 on 12/25/25.
//

import SwiftUI

struct Login_Button: View {
    @StateObject private var viewModel = LoginViewModel()

    // ✅ 화면 이동용 상태만 추가
    @State private var goMain: Bool = false

    var body: some View {
        ZStack {
            Button(action: {
                //  로그인 로직 무시하고 바로 이동
                goMain = true
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
            .frame(width: 300, height: 45)
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(30)
            .disabled(viewModel.isLoading)

            //  UI에 전혀 영향 없는 숨겨진 네비게이션
            NavigationLink(
                destination: Mainpage_View(),
                isActive: $goMain
            ) {
                EmptyView()
            }
            .hidden()
        }
    }
}

#Preview {
    Login_Button()
}
