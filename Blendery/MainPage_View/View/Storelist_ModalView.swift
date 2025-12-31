import SwiftUI

struct StoreSelectPanel: View {
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("등록된 매장")
                    .font(.system(size: 16, weight: .bold))

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }

            VStack(spacing: 0) {
                Button(action: { print("이디야 1호점") }) {
                    Image("이디야 로고")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 105, height: 11)   // 원하는 크기로 조절
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                
                Divider()
                
                Button(action: { print("이디야 1호점") }) {
                    Image("스벅 로고")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 105, height: 11)   // 원하는 크기로 조절
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                
                Divider()
                
                Button(action: { print("이디야 1호점") }) {
                    Image("데삼구 로고")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 105, height: 11)   // 원하는 크기로 조절
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16) //  내부 여백만 (cornerRadius/shadow/가로 padding 없음)
    }
}

#Preview {
    StoreSelectPanel(onClose: {})
}
