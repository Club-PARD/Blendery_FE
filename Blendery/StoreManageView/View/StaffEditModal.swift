// ===============================
//  StaffEditModal.swift
//  Blendery
// ===============================

import SwiftUI

struct StaffEditModal: View {

    //  입력(편집 대상)
    let member: StaffMember

    //  콜백
    let onSave: (StaffMember) -> Void
    let onDelete: (StaffMember) -> Void
    let onClose: () -> Void

    //  상태 변수
    //  - 드롭다운 열림/닫힘
    @State private var isDropdownOpen: Bool = false

    //  상태 변수
    //  - 임시 편집 값(저장 전)
    @State private var tempRole: StaffMember.Role = .staff

    //  상태 변수
    //  - 삭제 확인 팝업
    @State private var showDeleteConfirm: Bool = false

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97)
                .ignoresSafeArea()

            VStack(spacing: 12) {

                Text("편집")
                    .font(.system(size: 18, weight: .bold))
                    .padding(.top, 6)

                VStack(spacing: 8) {

                    dropdownHeader()

                    if isDropdownOpen {
                        dropdownOptions()
                    }

                    HStack {
                        Spacer()
                        Button {
                            showDeleteConfirm = true
                        } label: {
                            Text("프로필 삭제")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 2)
                }

                Spacer()

                Button {
                    var updated = member
                    updated.role = tempRole
                    onSave(updated)
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

            if showDeleteConfirm {
                deleteConfirmOverlay()
            }
        }
        .onAppear {
            tempRole = member.role
        }
    }

    private func dropdownHeader() -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                isDropdownOpen.toggle()
            }
        } label: {
            HStack {
                Text(tempRole.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)

                Spacer()

                Image(systemName: isDropdownOpen ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color(red: 0.71, green: 0.71, blue: 0.71), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func dropdownOptions() -> some View {
        VStack(spacing: 0) {
            ForEach(StaffMember.Role.allCases) { r in
                Button {
                    tempRole = r
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isDropdownOpen = false
                    }
                } label: {
                    HStack {
                        Text(r.rawValue)
                            .font(.system(size: 16))
                            .foregroundStyle(.black)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(Color.white)
                }
                .buttonStyle(.plain)

                if r != StaffMember.Role.allCases.last {
                    Rectangle()
                        .fill(Color(red: 0.87, green: 0.87, blue: 0.87))
                        .frame(height: 1)
                        .padding(.horizontal, 10)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color(red: 0.71, green: 0.71, blue: 0.71), lineWidth: 1)
                )
        )
    }

    private func deleteConfirmOverlay() -> some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 46, weight: .bold))
                    .foregroundStyle(.gray)

                Text("프로필을 삭제하시겠습니까!?")
                    .font(.system(size: 16, weight: .semibold))

                HStack(spacing: 10) {
                    Button {
                        showDeleteConfirm = false
                    } label: {
                        Text("취소")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(red: 0.92, green: 0.92, blue: 0.92))
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        showDeleteConfirm = false
                        onDelete(member)
                    } label: {
                        Text("삭제")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.red)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 6)
            }
            .padding(18)
            .frame(maxWidth: 290)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
            )
        }
    }
}

#Preview {
    StaffEditModal(
        member: StaffMember(name: "이지수", startDateText: "2010.12.25~", role: .manager),
        onSave: { _ in },
        onDelete: { _ in },
        onClose: {}
    )
}
