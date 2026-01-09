//
//  SearchBarView.swift
//  Blendery
//

import SwiftUI
import UIKit

struct SearchBarView: View {
    // ✅ 상태 오브젝트 : 검색 VM
    @ObservedObject var vm: SearchBarViewModel
    
    // ✅ 외부 주입 값
    var placeholder: String = "메뉴 검색"
    var onSearchTap: (() -> Void)? = nil
    
    var onOpen: (() -> Void)? = nil
    
    // ✅ 포커스 바인딩(필수)
    var focus: FocusState<Bool>.Binding
    
    private let orange = Color(red: 0.89, green: 0.19, blue: 0)
    
    var body: some View {
        HStack(spacing: 10) {
            
            // ✅ 검색창(테두리 있는 박스)
            HStack(spacing: 10) {
                
                // ✅ 돋보기(왼쪽 고정)
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(orange)
                    .padding(.leading, 18)
                
                // ✅ 텍스트필드
                TextField(placeholder, text: $vm.text)
                    .focused(focus)
                    .onTapGesture {                         onOpen?()
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .padding(.vertical, 12)
                    .submitLabel(.search)
                    .onSubmit {
                        onSearchTap?()
                    }
                
                    .onChange(of: vm.text) { _ in
                        Task {
                            await vm.search()
                        }
                    }
                
                Spacer()
                
                
                if vm.isFocused && vm.hasText {
                    Button { vm.clearText() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.gray.opacity(0.7))
                            .padding(.trailing, 14)
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear
                        .frame(width: 18, height: 18)
                        .padding(.trailing, 14)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color(red: 1.0, green: 0.92, blue: 0.92).opacity(0.35))   // ✅ 연한 빨간색(핑크톤)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(orange, lineWidth: 1.5)
            )
            .cornerRadius(30)
            .frame(height: 50)
            
            // ✅ 오른쪽 큰 X(검색 종료)
            if vm.isFocused {
                Button {
                    vm.close()
                    focus.wrappedValue = false
                    hideKeyboard()
                } label: {
                    Text("닫기")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 136/255, green: 136/255,blue: 136/255))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        
        // ✅ FocusState 동기화(양방향) — Mainpage_View에서 빼고 여기서 해결
        .onChange(of: vm.isFocused) { newValue in
            if focus.wrappedValue != newValue {
                focus.wrappedValue = newValue
            }
        }
        .onChange(of: focus.wrappedValue) { newValue in
            if vm.isFocused != newValue {
                vm.isFocused = newValue
                if newValue == false {
                    // 포커스가 꺼질 때 텍스트 유지/삭제는 vm.close() 정책에 따름
                }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
