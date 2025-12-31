//
//  AuthService.swift
//  Blendery
//
//  Created by 박성준 on 12/24/25.
//

import Foundation

final class AuthService {
    func login(request: LoginRequest) async throws -> String {
        let url = URL(string: "baseURL/login")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
        return decoded.accessToken
    }
}
