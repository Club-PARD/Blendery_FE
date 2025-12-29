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

    func request<T: Decodable>(
        url: URL,
        token: String,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
