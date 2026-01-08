//
//  LogoutConfirmPopup.swift
//  Blendery
//
//  Created by 박영언 on 1/8/26.
//

import SwiftUI

struct LogoutConfirmPopup: View {
    
    let onCancel: () -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {

            Image("느낌표")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 96)

            Text("로그아웃 하시겠습니까?")
                .font(.headline)
                .font(.system(size: 15))

            HStack(spacing: 12) {

                Button("취소") {
                    onCancel()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(10)
                .foregroundColor(.black)
                .font(.system(size: 15))

                Button("로그아웃") {
                    onConfirm()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10)
                .font(.system(size: 15))
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .frame(maxWidth: 300)
        
    }
}
