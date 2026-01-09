import SwiftUI
import Combine
import UIKit

struct StaffAddModal: View {

    // ===============================
    //  상태 변수
    // ===============================
    @State private var emailText: String = ""
    @FocusState private var isEmailFocused: Bool

    // ===============================
    //  콜백
    // ===============================
    let onSend: (String) -> Void
    let onClose: () -> Void

    // ===============================
    //  UI
    // ===============================
    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97)
                .ignoresSafeArea()

            VStack(spacing: 14) {

                Text("직원 추가")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.top, 10)

                emailField()

                sendButton()

                closeButton()

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 6)

            // ✅ 키보드 영향 덜 받게: 모달 컨텐츠 자체를 위로 끌어올림
            // (포커스가 잡혔을 때만 살짝 위로)
            .offset(y: isEmailFocused ? -80 : 0)
            .animation(.easeOut(duration: 0.18), value: isEmailFocused)
        }
        // ✅ 키보드 영역을 무시해서 시트가 아래로 눌리지 않게
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    // ===============================
    //  UI 컴포넌트
    // ===============================
    private func emailField() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.95, green: 0.95, blue: 0.95))

            TextField(
                "",
                text: $emailText,
                prompt: Text("000000@gmail.com")
                    // ✅ placeholder 글자색 “확실히 회색”
                    .foregroundStyle(Color(red: 0.60, green: 0.60, blue: 0.60))
                    .font(.system(size: 18, weight: .regular))
            )
            .focused($isEmailFocused)
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .autocorrectionDisabled(true)
            .font(.system(size: 18, weight: .regular))
            .foregroundStyle(.black)
            .padding(.horizontal, 18)
            .frame(height: 64)
        }
        .frame(height: 64)
    }

    private func sendButton() -> some View {
        Button {
            let trimmed = emailText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            onSend(trimmed)
            onClose()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.black)

                Text("초대메일 발송하기")
                    // ✅ “조금 얇게” (semibold -> medium)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
            }
            .frame(height: 64)
        }
        .buttonStyle(.plain)
    }

    private func closeButton() -> some View {
        Button {
            onClose()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    // ✅ 닫기 버튼 배경 “연한 회색”
                    .fill(Color(red: 0.93, green: 0.93, blue: 0.93))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )

                Text("닫기")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
            }
            .frame(height: 64)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StaffAddModal(
        onSend: { _ in },
        onClose: {}
    )
}
