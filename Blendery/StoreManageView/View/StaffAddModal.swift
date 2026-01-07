// ===============================
//  StaffAddModal.swift
//  Blendery
// ===============================

import SwiftUI

struct StaffAddModal: View {

    //  상태 변수
    //  - 입력값
    @State private var nameText: String = ""
    @State private var dateText: String = "2010.12.25~"
    @State private var role: StaffMember.Role = .staff

    //  콜백
    let onAdd: (String, String, StaffMember.Role) -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("추가")
                    .font(.system(size: 18, weight: .bold))
                    .padding(.top, 6)

                // 이름 입력
                inputField(title: "이름", text: $nameText, placeholder: "이름 입력")

                // 날짜(일단 텍스트)
                inputField(title: "시작일", text: $dateText, placeholder: "예: 2010.12.25~")

                // 역할 선택(간단 Picker)
                VStack(alignment: .leading, spacing: 6) {
                    Text("직책")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.gray)

                    Picker("", selection: $role) {
                        ForEach(StaffMember.Role.allCases) { r in
                            Text(r.rawValue).tag(r)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Spacer()

                Button {
                    let trimmed = nameText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    onAdd(trimmed, dateText, role)
                } label: {
                    Text("완료")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.black)
                        )
                }
                .buttonStyle(.plain)

                Button {
                    onClose()
                } label: {
                    Text("닫기")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color(red: 0.53, green: 0.53, blue: 0.53), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(24)
        }
    }

    private func inputField(
        title: String,
        text: Binding<String>,
        placeholder: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.gray)

            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color(red: 0.71, green: 0.71, blue: 0.71), lineWidth: 1)
                    )

                HStack(spacing: 10) {
                    TextField(placeholder, text: text)
                        .font(.system(size: 16))
                        .frame(height: 50)
                        .padding(.leading, 15)

                    Spacer()

                    if !text.wrappedValue.isEmpty {
                        Button {
                            text.wrappedValue = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(.gray)
                        }
                        .padding(.trailing, 20)
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview {
    StaffAddModal(onAdd: { _,_,_ in }, onClose: {})
}
