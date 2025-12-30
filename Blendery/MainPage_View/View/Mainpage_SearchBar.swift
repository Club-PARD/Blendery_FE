import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var placeholder: String = "검색"
    var onSearchTap: (() -> Void)? = nil

    // ✅ Mainpage_View에서 포커스 전달받기
    var focus: FocusState<Bool>.Binding? = nil

    var body: some View {
        HStack(spacing: 10) {
            Group {
                if let focus {
                    TextField(placeholder, text: $text)
                        .focused(focus)   // ✅ nil이 아닐 때만 연결
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.system(size: 16))
            .foregroundColor(.black)
            .padding(.leading, 18)
            .padding(.vertical, 12)
            .submitLabel(.search)

            Spacer()

            Button(action: {
                onSearchTap?()
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.89, green: 0.19, blue: 0))
                    .padding(.trailing, 18)
            }
            .buttonStyle(.plain)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color(red: 0.89, green: 0.19, blue: 0), lineWidth: 1.5)
        )
        .cornerRadius(30)
        .frame(height: 65)
        .padding(.horizontal, 16)
    }
}
