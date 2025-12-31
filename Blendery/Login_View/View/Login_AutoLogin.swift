//
//  Login_AutoLogin.swift
//  Blendery
//
//  Created by 박성준 on 12/25/25.
//

import SwiftUI

struct Login_AutoLogin: View {
    @State private var isAutoLogin = false

    var body: some View {
        HStack {
            Button {
                isAutoLogin.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isAutoLogin ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))

                    Text("자동 로그인")
                        .font(.system(size: 16))
                }
                .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
            }
            .buttonStyle(.plain) //  눌림 모션 제거

            Spacer()
        }
        .padding(.leading, 12)
    }
}

