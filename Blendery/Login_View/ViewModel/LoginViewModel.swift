//
//  LoginViewModel.swift
//  Blendery
//
//  Created by 박성준 on 12/24/25.
//

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

    // 서버 변수
    // - 로그인 요청(LoginRequest)
    @Published var email = ""
    @Published var password = ""

    // 상태 변수
    // - 로딩 스피너, 로그인 성공 후 화면 전환, 에러 토스트/텍스트 표시 등에 쓰임
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didLogin = false


    // 서버 변수
    // - AuthService 파일과 연결
    private let authService = AuthService()

    func login() {

        // ✅ 입력값 공백 제거 후 검증
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        // ✅ 입력 안 했을 때: 로그인 화면에 한국어 에러 띄우기
        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            errorMessage = "아이디(이메일)와 비밀번호를 입력해주세요."
            return
        }

        // 뷰 상태 변경 로딩 시작 + 에러 초기화
        isLoading = true
        didLogin = false
        errorMessage = nil

        Task {
            defer { isLoading = false }

            let request = LoginRequest(email: trimmedEmail, password: trimmedPassword)

            do {
                let token = try await authService.login(request: request)

                let userId = trimmedEmail
                
                // 토큰 저장
                KeychainHelper.shared.saveToken(token, for: userId)
                SessionManager.shared.currentUserId = userId

                print("로그인 성공")
                didLogin = true


            } catch let error as AuthError {
                // ✅ 서버 상태코드 기반 한국어 메시지
                errorMessage = error.localizedDescription

            } catch let error as URLError {
                // ✅ 네트워크 에러 한국어 처리
                switch error.code {
                case .notConnectedToInternet:
                    errorMessage = "인터넷 연결을 확인해주세요."
                case .timedOut:
                    errorMessage = "요청 시간이 초과되었습니다. 다시 시도해주세요."
                default:
                    errorMessage = "네트워크 오류가 발생했습니다. (\(error.code.rawValue))"
                }

            } catch {
                errorMessage = "알 수 없는 오류가 발생했습니다."
            }
        }
    }
}
