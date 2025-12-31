import SwiftUI
import UIKit

struct SearchBarView: View {
    @ObservedObject var vm: SearchBarViewModel

    var placeholder: String = "검색"
    var onSearchTap: (() -> Void)? = nil

    // 키보드 포커스는 View에서만 관리 (VM에 넣지 않는 게 정석)
    var focus: FocusState<Bool>.Binding? = nil

    private let orange = Color(red: 0.89, green: 0.19, blue: 0)

    var body: some View {
        HStack(spacing: 10) {

            //  검색창(테두리 있는 박스)
            HStack(spacing: 10) {

                //  돋보기: 항상 왼쪽 고정
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(orange)
                    .padding(.leading, 18)

                //  텍스트필드
                Group {
                    if let focus {
                        TextField(placeholder, text: $vm.text)
                            .focused(focus)
                            .onTapGesture { vm.open() }
                    } else {
                        TextField(placeholder, text: $vm.text)
                            .onTapGesture { vm.open() }
                    }
                }
                .font(.system(size: 16))
                .foregroundColor(.black)
                .padding(.vertical, 12)
                .submitLabel(.search)

                Spacer()

                //  검색 켜졌고 + 텍스트 있을 때만: 오른쪽 전체 지우기 X(작은거)
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
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(orange, lineWidth: 1.5)
            )
            .cornerRadius(30)
            .frame(height: 50)

            //  오른쪽 큰 X(검색 종료)
            if vm.isFocused {
                Button {
                    vm.close()
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
