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
//            Mainpage_View()
            NavigationStack {
                OnboardingAnimationView()
                    .ignoresSafeArea(.keyboard, edges: .all)
            }
        }
    }
}

