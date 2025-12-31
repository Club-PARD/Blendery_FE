//
//  RecipeStepCell.swift
//  Blendery
//
//  Created by 박영언 on 12/26/25.
//

import SwiftUI

struct RecipeStepCell: View {
    let index: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 11) {
            Text("\(index)")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(red: 170/255, green: 170/255, blue: 170/255, opacity: 1))
                .frame(width: 32, height: 32)
                .background(Color(red: 246/255, green: 246/255, blue: 246/255, opacity: 1))
                .clipShape(Circle())
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10.71)
                .stroke(Color(red: 239/255, green: 239/255, blue: 239/255, opacity: 1), lineWidth: 1)
        )
    }
}

#Preview {
    RecipeStepCell(index: 1, text: "에스프레소 2샷")
}
