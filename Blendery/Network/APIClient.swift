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
    
    func fetchFavorites(cafeId: String) async throws -> FavoriteResponse {
        guard let userId = SessionManager.shared.currentUserId else {
            print("⛔️ fetchFavorites: userId is nil")
            throw URLError(.userAuthenticationRequired)
        }

        // authorities 배열을 JSON 문자열로 인코딩 (URL 인코딩은 URLComponents가 자동 처리)
        let authoritiesArray: [[String: String]] = [["authority": "string"]]
        guard let authoritiesData = try? JSONSerialization.data(withJSONObject: authoritiesArray),
              let authoritiesString = String(data: authoritiesData, encoding: .utf8) else {
            throw URLError(.badURL)
        }

        var components = URLComponents(string: "\(baseURL)/api/recipe/recipe-favorites")!
        // curl 예시에 따라 user 객체의 각 필드를 개별 query 파라미터로 전송
        // memberId는 현재 userId 사용 (실제 UUID가 필요하면 JWT에서 추출 필요)
        components.queryItems = [
            URLQueryItem(name: "memberId", value: userId),
            URLQueryItem(name: "password", value: "string"),
            URLQueryItem(name: "authorities", value: authoritiesString),
            URLQueryItem(name: "credentialsNonExpired", value: "true"),
            URLQueryItem(name: "accountNonLocked", value: "true"),
            URLQueryItem(name: "accountNonExpired", value: "true"),
            URLQueryItem(name: "username", value: userId),
            URLQueryItem(name: "enabled", value: "true"),
            URLQueryItem(name: "cafeId", value: cafeId)
        ]

        guard let url = components.url else { throw URLError(.badURL) }

        var request = try makeAuthorizedRequest(url: url, userId: userId)
        request.httpMethod = "GET"  // ✅ 명시 추천

        print("➡️ fetchFavorites REQUEST:", url.absoluteString)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse {
            print("📡 favorites statusCode:", http.statusCode)
        }
        print("📦 favorites raw response:", String(data: data, encoding: .utf8) ?? "nil")

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(FavoriteResponse.self, from: data)
    }

    
    func fetchMyCafes() async throws -> [Cafe] {
        guard let userId = SessionManager.shared.currentUserId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let url = URL(string: "\(baseURL)/api/members/staff/cafes")!
        let request = try makeAuthorizedRequest(url: url, userId: userId)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let http = response as? HTTPURLResponse {
            print("📡 cafes statusCode:", http.statusCode)
        }
        print("📦 cafes raw response:", String(data: data, encoding: .utf8) ?? "nil")
        
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
        
        let res = try JSONDecoder().decode(MemberCafesResponse.self, from: data)
        return res.cafes
    }
}
