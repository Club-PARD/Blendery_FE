//
//  TemparatureSegment.swift
//  Blendery
//
//  Created by 박영언 on 12/28/25.
//

import SwiftUI

struct TemperatureSegment: View {
    @Binding var selected: Temperature
    
    var body: some View {
        HStack(spacing: 4) {
            PillSegment(
                title: "HOT",
                isSelected: selected == .hot
            ) {
                selected = .hot
            }
            
            PillSegment(
                title: "ICE",
                isSelected: selected == .ice
            ) {
                selected = .ice
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
