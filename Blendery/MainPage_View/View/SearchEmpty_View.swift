//
//  SearchEmpty_View.swift
//  Blendery
//
//  Created by 박성준 on 12/30/25.
//

import SwiftUI

struct SearchEmpty_View: View {
    var body: some View {
        VStack {
            Image("empty")
                .resizable()
                .scaledToFit()
                .frame(width: 68, height: 90)
                .padding(.bottom, 24)
            
            Text("저장된 레시피가 없습니다.")
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                .font(.system(size: 15))
                .padding(.bottom, 1)
            Text("검색어를 다시 한번 확인해주세요.")
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                .font(.system(size: 15))
                
        }
    }
}

#Preview {
    SearchEmpty_View()
}
