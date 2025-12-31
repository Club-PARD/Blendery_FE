//
//  login view.swift
//  Blendary
//
//  Created by 박성준 on 12/24/25.
//

import SwiftUI

struct LoginView: View {
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    
                    Login_Logo()
                        .padding(.bottom,38)
                    
                    Login_ID_PW()
                    
                    Login_AutoLogin()
                        .padding(.vertical, 16)
                        
                    Login_Button()
                        
                        

                    Spacer()
                }
                    .padding(.horizontal, 50)
            }
            
        }
        
    }
}



// 로그인 성공 후 보여질 홈 화면 예시
// 로그인 성공 후 보여지는 HomeView라고 가정



// 미리보기
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

