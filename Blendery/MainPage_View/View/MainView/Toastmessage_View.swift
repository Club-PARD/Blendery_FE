//
//  Toastmessage_View.swift
//  Blendery
//
//  Created by 박성준 on 1/3/26.
//

import SwiftUI

struct Toastmessage_View: View {
    let message: String
    let iconName: String?

    var body: some View {
        HStack(spacing: 8) {
            if let iconName {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }

            Text(message)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.gray.opacity(0.85))
        .clipShape(Capsule())
        .shadow(radius: 6, y: 3)
    }
}

