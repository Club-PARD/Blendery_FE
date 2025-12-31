//
//  SizeSegment.swift
//  Blendery
//
//  Created by 박영언 on 12/28/25.
//

import SwiftUI

struct SizeSegment: View {
    @Binding var selected: CupSize

    var body: some View {
        HStack(spacing: 4) {
            PillSegment(
                title: "L",
                isSelected: selected == .l
            ) {
                selected = .l
            }

            PillSegment(
                title: "XL",
                isSelected: selected == .xl
            ) {
                selected = .xl
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color.white)
                .frame(height: 38.852)
        )
    }
}
