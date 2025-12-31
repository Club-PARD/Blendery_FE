//
//  BlenderyAPI.swift.swift
//  Blendery
//
//  Created by 박성준 on 12/31/25.
//

import Foundation

final class BlenderyAPI {
    static let shared = BlenderyAPI()

    //  baseURL은 "루트"만 (끝에 / 붙여도 되고 안 붙여도 됨)
    let baseURL: URL = {
        guard let url = URL(string: BaseURL.value) else {
            fatalError("❌ Invalid BaseURL: \(BaseURL.value)")
        }
        return url
    }()

    private init() {}

    func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
