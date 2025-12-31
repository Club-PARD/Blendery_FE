//
//  LoginViewModel.swift
//  Blendery
//
//  Created by 박성준 on 12/24/25.
//

import SwiftUI
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    @Published var isLoading = false
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    
    // AuthService가 있다고 가정 (MockAuthService 등)
    private let authService = AuthService()
    
    func login() {
        // 간단한 입력 확인
        guard !email.isEmpty, !password.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        
        Task {
            
            defer { isLoading = false }
            
            let request = LoginRequest(email: email, password: password)
            
            do {
                
                let token = try await authService.login(request: request)
                
                saveToken(token)
                isLoggedIn = true
                print("로그인 성공")
            } catch {
                print("에러 발생: \(error)")
                errorMessage = "로그인 실패: \(error.localizedDescription)"
            }
        }
    }
    
    private func saveToken(_ token: String) {
        KeychainHelper.shared.saveToken(token: token)
    }
}
