//
//  RecipeTitle.swift
//  Blendery
//
//  Created by 박영언 on 12/26/25.
//

import SwiftUI

struct RecipeTitle: View {
    let menu: MenuCardModel
    let optionTags: [String]
    let thumbnailURL: URL?

    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(Color(red: 217/255, green: 217/255, blue: 217/255, opacity: 1.0))
                    .frame(width: 70, height: 70)
                    .cornerRadius(10)
                if let url = thumbnailURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable().scaledToFit()
                        default:
                            Image("상세 로딩")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                        }
                    }
                    .frame(width: 70, height: 70)
                }else {
                    Image("상세 로딩")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                }
            }

            VStack {
                HStack {
                    OptionBadge(
                        tags: optionTags
                    )
                    .padding(.bottom, 8)
                    Spacer()
                    FavoriteButton()
                }

                Text(menu.title)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

//#Preview {
//    RecipeTitle(
//        menu: MenuCardModel(
//            category: "커피",
//            tags: ["ICE"], // ✅ 추가
//            title: "카페모카",
//            subtitle: "에스프레소 2샷",
//            lines: ["에스프레소 2샷", "초코소스 2펌프", "우유 윗선"],
//            isBookmarked: false
//        )
//    )
//}
