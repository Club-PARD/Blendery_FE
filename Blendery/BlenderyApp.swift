//
//  BlenderyApp.swift
//  Blendery
//
//  Created by 박영언 on 12/24/25.
//

import SwiftUI

@main
struct BlenderyApp: App {
    var body: some Scene {
        WindowGroup {
            ProfileView(
                profile: UserProfile(
                    name: "이지수",
                    role: "매니저",
                    joinedAt: "2010.12.25~",
                    phone: "010-7335-1790",
                    email: "l_oxo_l@handong.ac.kr"
                )
            )
        }
    }
}

