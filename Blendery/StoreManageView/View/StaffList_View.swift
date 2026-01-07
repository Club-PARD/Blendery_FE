// ===============================
//  StaffList_View.swift
//  Blendery
// ===============================

import SwiftUI
import UIKit

struct StaffList_View: View {

    //  상태/데이터 변수
    //  - UI만 먼저 만들기용(메모리 저장)
    @StateObject private var store = StaffStore()

    //  상태 변수
    //  - 편집할 멤버(선택된 멤버)
    @State private var selectedMember: StaffMember? = nil

    //  상태 변수
    //  - 추가 모달 표시
    @State private var showAddModal: Bool = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.97, green: 0.97, blue: 0.97)
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    // 상단 바
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.black)
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Text("매장 관리")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.black)

                        Spacer()

                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    .padding(.top, 6)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 18) {

                            // -------------------------
                            // 매니저 섹션
                            // -------------------------
                            sectionTitle("매니저")

                            cardContainer {
                                memberList(
                                    members: store.managers,
                                    onTapEdit: { member in
                                        selectedMember = member
                                    }
                                )
                            }

                            // -------------------------
                            // 스태프 섹션
                            // -------------------------
                            sectionTitle("스태프")

                            cardContainer {
                                memberList(
                                    members: store.staffs,
                                    onTapEdit: { member in
                                        selectedMember = member
                                    }
                                )
                            }

                            // 추가 버튼(우하단)
                            HStack {
                                Spacer()
                                Button {
                                    showAddModal = true
                                } label: {
                                    Text("추가 +")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.black)
                                }
                                .buttonStyle(.plain)
                                .padding(.trailing, 18)
                                .padding(.top, 2)
                            }
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                }
            }
            // 편집 Modal
            .sheet(item: $selectedMember) { member in
                StaffEditModal(
                    member: member,
                    onSave: { updated in
                        store.update(updated)
                        selectedMember = nil
                    },
                    onDelete: { target in
                        store.delete(target)
                        selectedMember = nil
                    },
                    onClose: {
                        selectedMember = nil
                    }
                )
                .presentationDetents([.fraction(0.7)])
                .presentationDragIndicator(.visible)
            }
            // 추가 Modal
            .sheet(isPresented: $showAddModal) {
                StaffAddModal(
                    onAdd: { name, dateText, role in
                        store.add(name: name, startDateText: dateText, role: role)
                        showAddModal = false
                    },
                    onClose: {
                        showAddModal = false
                    }
                )
                .presentationDetents([.fraction(0.7)])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

// MARK: - UI 컴포넌트(내부)

private extension StaffList_View {

    // [레이아웃 상수]
    // - 사진 느낌 맞추기용
    var sidePadding: CGFloat { 18 }
    var cardRadius: CGFloat { 20 }
    var rowVPadding: CGFloat { 14 }

    func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, sidePadding + 6)
            .padding(.top, title == "매니저" ? 6 : 2)
    }

    func cardContainer(@ViewBuilder content: () -> some View) -> some View {
        RoundedRectangle(cornerRadius: cardRadius, style: .continuous)
            .fill(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: cardRadius, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
            .overlay(
                content()
                    .padding(.vertical, 6)
            )
            .padding(.horizontal, sidePadding)
    }

    func memberList(
        members: [StaffMember],
        onTapEdit: @escaping (StaffMember) -> Void
    ) -> some View {

        VStack(spacing: 0) {

            if members.isEmpty {
                Text("등록된 프로필이 없습니다.")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
            } else {
                ForEach(Array(members.enumerated()), id: \.element.id) { idx, member in

                    HStack(spacing: 12) {

                        profileImage()
                            .frame(width: 46, height: 46)
                            .opacity(0.95)

                        VStack(alignment: .leading, spacing: 5) {

                            HStack(spacing: 6) {
                                Text(member.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.black)

                                roleBadge(member.role.rawValue)
                            }

                            Text(member.startDateText)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(Color.gray.opacity(0.85))
                        }

                        Spacer()

                        Button {
                            onTapEdit(member)
                        } label: {
                            editIcon()
                                .frame(width: 30, height: 30)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, rowVPadding)

                    if idx != members.count - 1 {
                        Rectangle()
                            .fill(Color(red: 0.86, green: 0.86, blue: 0.86))
                            .frame(height: 1)
                            .padding(.horizontal, 18)
                    }
                }
            }
        }
    }

    func roleBadge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Color.black.opacity(0.85))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.black.opacity(0.12), lineWidth: 1)
                    )
            )
    }

    func profileImage() -> some View {
        let img = UIImage(named: "매장 관리 프로필")
            ?? UIImage(systemName: "person.crop.circle.fill")!

        return Image(uiImage: img)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.gray)
    }

    func editIcon() -> some View {
        if UIImage(named: "수정 아이콘") != nil {
            return AnyView(
                Image("수정 아이콘")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.gray)
            )
        } else {
            return AnyView(
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.gray)
            )
        }
    }
}

#Preview {
    StaffList_View()
}
