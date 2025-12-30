import SwiftUI
import UIKit

struct SearchBarView: View {
    @Binding var text: String
    var placeholder: String = "검색"
    var onSearchTap: (() -> Void)? = nil

    var focus: FocusState<Bool>.Binding? = nil
    @Binding var isFocused: Bool

    private let orange = Color(red: 0.89, green: 0.19, blue: 0)

    private var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(spacing: 10) {

            // ✅ 검색창(테두리 있는 박스)
            HStack(spacing: 10) {

                // ✅ 돋보기: 항상 왼쪽 고정(절대 안 사라짐)
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(orange)
                    .padding(.leading, 18)

                // ✅ 텍스트필드
                Group {
                    if let focus {
                        TextField(placeholder, text: $text)
                            .focused(focus)
                            .onTapGesture { isFocused = true }
                    } else {
                        TextField(placeholder, text: $text)
                            .onTapGesture { isFocused = true }
                    }
                }
                .font(.system(size: 16))
                .foregroundColor(.black)
                .padding(.vertical, 12)
                .submitLabel(.search)

                Spacer()

                // ✅ 검색 켜졌고 + 텍스트 있을 때만: 오른쪽 전체 지우기 X
                if isFocused && hasText {
                    Button { text = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.gray.opacity(0.7))
                            .padding(.trailing, 14)
                    }
                    .buttonStyle(.plain)
                } else {
                    // ✅ 오른쪽 여백 유지(레이아웃 흔들림 방지)
                    Color.clear
                        .frame(width: 18, height: 18)
                        .padding(.trailing, 14)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(orange, lineWidth: 1.5)
            )
            .cornerRadius(30)
            .frame(height: 50)

            // ✅ 오른쪽 큰 X(검색 종료)
            if isFocused {
                Button {
                    text = ""
                    isFocused = false
                    if let focus { focus.wrappedValue = false }
                    hideKeyboard()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(orange)
                        .frame(width: 42, height: 42)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(orange, lineWidth: 1.3))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
