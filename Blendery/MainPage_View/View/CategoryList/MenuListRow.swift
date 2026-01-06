//
//  MenuListRow.swift
//  Blendery
//
//  일반 카테고리 리스트 한 줄 UI
//

import SwiftUI
import UIKit

struct MenuListRow: View {
    
    // 서버 데이터
    // 한 줄에 표시할 메뉴 데이터
    let model: MenuCardModel
    
    // 서버 호출
    // 즐겨찾기 같은 상태 변경 트리거
    let onToggleBookmark: () -> Void
    
    // 화면 이동용 이벤트
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                
                // UI 이미지 표시 로직
                rowImage
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.category)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text(model.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .background(Color.white)
        }
        .buttonStyle(.plain)
    }
    
    private var thumbnailURL: URL? {
        // 1) HOT 우선
        if let s = model.hotThumbnailUrl, !s.isEmpty, let url = URL(string: s) {
            return url
        }
        // 2) HOT 없으면 ICE로 fallback
        if let s = model.iceThumbnailUrl, !s.isEmpty, let url = URL(string: s) {
            return url
        }
        return nil
    }
    
    private var rowImage: some View {
        // 이미지 로딩 상태값
        // 서버 이미지 로딩과 연관 가능성은 있지만 여기서는 표시만 분기
        if model.isImageLoading {
            return AnyView(
                ZStack {
                    Color.white
                    Image("vertical loading")
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                }
            )
        }
        if let url = thumbnailURL {
            return AnyView(
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Color(red: 0.95, green: 0.95, blue: 0.95)
                            ProgressView()
                        }
                        
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                        
                    default:
                        // 실패 시 기존 placeholder
                        ZStack {
                            Color(red: 0.95, green: 0.95, blue: 0.95)
                            Image("loading")
                                .resizable()
                                .scaledToFit()
                                .padding(8)
                        }
                    }
                }
            )
        }
        let name = model.imageName ?? model.title
        if UIImage(named: name) != nil {
            return AnyView(
                Image(name)
                    .resizable()
                    .scaledToFill()
            )
        }
        
        // 기본 플레이스홀더
        return AnyView(
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.95)
                Image("loading")
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            }
        )
    }
}
