//
//  APIClient.swift
//  Blendery
//
//  Created by 박영언 on 12/29/25.
//

import Foundation

final class APIClient {
    
    static let shared = APIClient()
    private init() {}
    
    private let baseURL = BaseURL.baseUrl.rawValue
    
    private func makeAuthorizedRequest(
        url: URL,
        userId: String
    ) throws -> URLRequest {
        
        guard let token = KeychainHelper.shared.readToken(for: userId) else {
            throw URLError(.userAuthenticationRequired)
        }
        
        var request = URLRequest(url: url)
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )
        
        //디버그용 (잘 되면 삭제)
        print("🔐 Authorization: Bearer \(token.prefix(20))...")
        
        return request
    }
    
    func fetchRecipes(
        franchiseId: String,
        category: String? = nil,
        favorite: Bool? = nil
    ) async throws -> [RecipeModel] {
        guard let userId = SessionManager.shared.currentUserId else {
            print("⛔️ API 차단 - 로그아웃 상태")
            return []
        }
        
        var components = URLComponents(string: "\(baseURL)/api/recipe/recipes")!
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "franchiseId", value: franchiseId)
        ]
        
        if let category {
            queryItems.append(
                URLQueryItem(name: "category", value: category)
            )
        }
        
        if let favorite {
            queryItems.append(
                URLQueryItem(name: "favorite", value: String(favorite))
            )
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let request = try makeAuthorizedRequest(url: url, userId: userId)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let http = response as? HTTPURLResponse {
            print("📡 statusCode:", http.statusCode)
        }
        
        print("📦 raw response:", String(data: data, encoding: .utf8) ?? "nil")
        
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([RecipeModel].self, from: data)
    }
    
    func searchRecipes(
        keyword: String
    ) async throws -> [SearchRecipeModel] {
        guard let userId = SessionManager.shared.currentUserId else {
            print("⛔️ API 차단 - 로그아웃 상태")
            return []
        }
        
        var components = URLComponents(
            string: "\(baseURL)/api/recipe/search/recipes"
        )!
        
        components.queryItems = [
            URLQueryItem(name: "keyword", value: keyword)
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let request = try makeAuthorizedRequest(url: url, userId: userId)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([SearchRecipeModel].self, from: data)
    }
    
    func fetchRecipeDetail(
        recipeId: UUID
    ) async throws -> RecipeModel {
        guard let userId = SessionManager.shared.currentUserId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let url = URL(string: "\(baseURL)/api/recipe/\(recipeId.uuidString)")!
        
        let request = try makeAuthorizedRequest(url: url, userId: userId)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(RecipeModel.self, from: data)
    }
}
