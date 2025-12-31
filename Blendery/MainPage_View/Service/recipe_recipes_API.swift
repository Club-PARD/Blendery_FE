//
//  recipe_recipes_API.swift
//  Blendery
//
//  Created by 박성준 on 12/31/25.
//

import Foundation

extension BlenderyAPI {

    /// franchiseId / category / favorite 조건으로 레시피 검색
    func searchRecipes(
        franchiseId: String,
        category: String? = nil,
        favorite: Bool? = nil
    ) async throws -> [RecipeModel] {

        let endpoint = baseURL.appendingPathComponent("api/recipe/search/recipes")

        guard var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }

        var items: [URLQueryItem] = [
            URLQueryItem(name: "franchiseId", value: franchiseId)
        ]

        if let category, !category.isEmpty {
            items.append(URLQueryItem(name: "category", value: category))
        }

        if let favorite {
            items.append(URLQueryItem(name: "favorite", value: favorite ? "true" : "false"))
        }

        components.queryItems = items

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response)

        return try JSONDecoder().decode([RecipeModel].self, from: data)
    }
}
