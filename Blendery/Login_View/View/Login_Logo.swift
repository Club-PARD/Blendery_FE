//
//  Login_Logo.swift
//  Blendery
//
//  Created by 박성준 on 12/25/25.
//

import SwiftUI

struct Login_Logo: View {
    var body: some View {
        VStack() {
            HStack {
                Spacer()
                Image("로고")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 121, height: 120)
                Spacer()
            }
        }
    }
}
