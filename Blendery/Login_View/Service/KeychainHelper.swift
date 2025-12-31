//
//  KeychainService.swift
//  Blendery
//
//  Created by 박성준 on 12/24/25.
//

import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()
    private let serviceName = "com.blendary.app" // 앱 식별자
    
    // 1. 토큰 저장 (Save)
    func saveToken(token: String) {
        let data = Data(token.utf8)
        
        // 기존 데이터 삭제 (중복 방지)
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
        ] as [String: Any]
        SecItemDelete(query as CFDictionary)
        
        // 새 데이터 추가
        let attributes = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecValueData: data
        ] as [String: Any]
        
        SecItemAdd(attributes as CFDictionary, nil)
    }
    
    // 2. 토큰 읽기 (Read)
    func readToken(account: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as [String: Any]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess, let data = item as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    // 3. 토큰 삭제 (Delete - 로그아웃 시 사용)
    func deleteToken() {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
        ] as [String: Any]
        SecItemDelete(query as CFDictionary)
    }
}
