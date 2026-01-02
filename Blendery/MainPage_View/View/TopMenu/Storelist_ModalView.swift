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
                    HStack {
                        Image("이디야 로고")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 105, height: 11)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle()) // ✅ 줄 전체 터치
                }
                .buttonStyle(.plain)

                Divider()

                Button(action: { print("스벅 1호점") }) {
                    HStack {
                        Image("스벅 로고")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 105, height: 11)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle()) // ✅ 줄 전체 터치
                }
                .buttonStyle(.plain)

                Divider()

                Button(action: { print("데삼구 1호점") }) {
                    HStack {
                        Image("데삼구 로고")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 105, height: 11)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle()) // ✅ 줄 전체 터치
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
    }
}

#Preview {
    StoreSelectPanel(onClose: {})
}
