//
//  OnboardingView.swift
//  Blendery
//
//  Created by 박성준 on 12/26/25.
//

import SwiftUI

struct OnboardingView: View {
    let namespace: Namespace.ID
    @Binding var showLogin: Bool

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Image("로고")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .matchedGeometryEffect(
                    id: "logo",
                    in: namespace,
                    isSource: true
                )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeInOut(duration: 1)) {
                    showLogin = true
                }
            }
        }
    }
}
