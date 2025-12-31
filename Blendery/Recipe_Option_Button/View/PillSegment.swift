//
//  SwiftUIView.swift
//  Blendery
//
//  Created by 박영언 on 12/26/25.
//

import SwiftUI

struct PillSegment: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(isSelected ? .white : Color(red: 114/255, green: 114/255, blue: 114/255, opacity: 1))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(red: 60/255, green: 60/255, blue: 60/255, opacity: 1) : Color.clear)
                        .frame(width: 76.675)
                )
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    HStack(spacing: 12) {
        PillSegment(title: "HOT", isSelected: false, action: {})
        PillSegment(title: "ICE", isSelected: true, action: {})
    }
    .padding()
}
