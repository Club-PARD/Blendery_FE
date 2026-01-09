//
//  StaffList_View.swift
//  Blendery
//

import SwiftUI
import UIKit
import Combine

// ===============================
//  StaffList_View.swift
// ===============================

struct StaffList_View: View {

    // ===============================
    //  상태 변수 - 토스트
    // ===============================

    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""

    // ===============================
    //  상태/데이터 변수
    // ===============================

    @StateObject private var store: StaffStore
    init(store: StaffStore = StaffStore()) {
        _store = StateObject(wrappedValue: store)
    }

    @State private var showAddModal: Bool = false
    @State private var roleEditTarget: StaffMember? = nil
    @State private var deleteTarget: StaffMember? = nil

    // ===============================
    //  리스트 화면 기준 “중앙 경고창” 상태
    // ===============================

    private enum ConfirmMode {
        case roleChange
        case delete
    }

    @State private var showConfirm: Bool = false
    @State private var confirmMode: ConfirmMode = .delete
    @State private var roleChangeTarget: StaffMember? = nil
    @State private var pendingRole: StaffMember.Role? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.97, green: 0.97, blue: 0.97)
                    .ignoresSafeArea()

                // ✅ 아래 화면(리스트/버튼) : 경고창 떠있을 때 터치/스크롤/버튼 전부 차단
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {

                        sectionTitle("매니저")
                        cardContainer { memberList(members: store.managers) }

                        sectionTitle("스태프")
                        cardContainer { memberList(members: store.staffs) }

                        HStack {
                            Spacer()

                            Button {
                                showAddModal = true
                            } label: {
                                Text("추가 +")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(.black)
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, sidePadding + 6)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 30)
                }
                .allowsHitTesting(!showConfirm)

                // ✅ 토스트 (리스트 화면 위)
                if showToast {
                    toastView(text: toastMessage)
                        .zIndex(999)
                        .allowsHitTesting(false)
                }

                // ✅ 중앙 경고창 (애니메이션 없이 "딱" 표시)
                if showConfirm {
                    confirmOverlayFullScreen()
                        .zIndex(1000)
                        .transition(.identity)
                }
            }
            .navigationTitle("직원 관리")
            .navigationBarTitleDisplayMode(.inline)

            // ✅ showConfirm 토글 애니메이션 자체 차단
            .animation(nil, value: showConfirm)
        }

        // ✅ 직급 변경 모달(편집 모달)
        .sheet(item: $roleEditTarget) { member in
            StaffEditModal(
                member: member,
                onSave: { updated in
                    store.update(updated)
                },
                onClose: {
                    roleEditTarget = nil
                }
            )
            .presentationDetents([.fraction(0.35)])
        }

        // ✅ 추가 모달
        .sheet(isPresented: $showAddModal) {
            StaffAddModal(
                onSend: { _ in
                    showToastMessage("발송 완료")
                },
                onClose: {
                    showAddModal = false
                }
            )
            .presentationDetents([.fraction(0.62)]) // ✅ 더 올라오게
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - 리스트 UI 컴포넌트
private extension StaffList_View {

    var sidePadding: CGFloat { 18 }
    var cardRadius: CGFloat { 20 }
    var rowVPadding: CGFloat { 20 }

    func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, sidePadding + 6)
            .padding(.top, title == "매니저" ? 6 : 2)
    }

    func cardContainer(@ViewBuilder content: () -> some View) -> some View {
        content()
            .background(
                RoundedRectangle(cornerRadius: cardRadius, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.03),
                            radius: 10, x: 0, y: 4)
            )
            .padding(.horizontal, sidePadding)
    }

    func memberList(members: [StaffMember]) -> some View {
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

                        HStack(spacing: 18) {
                            Button { roleEditTarget = member } label: {
                                Image("직원수정")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                            .buttonStyle(.plain)

                            Button { requestDeleteConfirm(member: member) } label: {
                                Image("직원삭제")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                            .buttonStyle(.plain)
                        }
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
        let img = UIImage(named: "직원관리프로필")
        ?? UIImage(systemName: "person.crop.circle.fill")!

        return Image(uiImage: img)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.gray)
    }
}

// MARK: - 리스트 화면 경고창 로직 + 토스트
private extension StaffList_View {

    // ✅ 애니메이션 없이 showConfirm = true
    func presentConfirmNoAnimation() {
        var t = Transaction()
        t.disablesAnimations = true
        withTransaction(t) {
            showConfirm = true
        }
    }

    func requestRoleChangeConfirm(member: StaffMember, newRole: StaffMember.Role) {
        guard member.role != newRole else { return }

        confirmMode = .roleChange
        roleChangeTarget = member
        pendingRole = newRole
        presentConfirmNoAnimation()
    }

    func requestDeleteConfirm(member: StaffMember) {
        confirmMode = .delete
        deleteTarget = member
        presentConfirmNoAnimation()
    }

    func cancelConfirm() {
        var t = Transaction()
        t.disablesAnimations = true
        withTransaction(t) {
            showConfirm = false
        }

        roleChangeTarget = nil
        pendingRole = nil
        deleteTarget = nil
    }

    func confirmAction() {
        switch confirmMode {

        case .roleChange:
            guard let target = roleChangeTarget,
                  let newRole = pendingRole else {
                cancelConfirm()
                return
            }

            var updated = target
            updated.role = newRole
            store.update(updated)

            roleEditTarget = nil
            cancelConfirm()

        case .delete:
            guard let target = deleteTarget else {
                cancelConfirm()
                return
            }

            store.delete(target)
            cancelConfirm()
        }
    }

    // ✅ 경고창(오버레이): 딤 영역도 터치 먹고, 아래 화면은 이미 allowsHitTesting(false)
    func confirmOverlayFullScreen() -> some View {
        ZStack {
            // 딤 처리(전체 화면) + 터치 먹기
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { } // 바깥 탭 무시
                .allowsHitTesting(true)

            // 팝업(정중앙)
            VStack(spacing: 12) {

                Image("느낌표")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 96)

                Text(confirmMode == .delete ? "프로필을 삭제하시겠습니까!?" : "직급을 변경하시겠습니까?")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)

                if confirmMode == .delete {
                    Text("삭제하면 되돌릴 수 없습니다.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.gray)
                        .padding(.top, -2)
                }

                HStack(spacing: 10) {
                    Button { cancelConfirm() } label: {
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

                    Button { confirmAction() } label: {
                        Text(confirmMode == .delete ? "삭제" : "변경")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(confirmMode == .delete ? Color.red : Color.black)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    // ===============================
    //  토스트
    // ===============================

    func showToastMessage(_ text: String) {
        toastMessage = text
        withAnimation(.easeInOut(duration: 0.15)) {
            showToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.15)) {
                showToast = false
            }
        }
    }

    func toastView(text: String) -> some View {
        VStack {
            Spacer()

            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.black.opacity(0.85))
                )
                .padding(.bottom, 18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
}

// ===============================
//  Preview
// ===============================

#Preview {
    let previewStore = StaffStore()
    previewStore.members = [
        StaffMember(name: "이지수", startDateText: "2010.12.25~", role: .manager),
        StaffMember(name: "김하늘", startDateText: "2022.03.01~", role: .manager),
        StaffMember(name: "박성준", startDateText: "2024.09.10~", role: .staff),
        StaffMember(name: "홍길동", startDateText: "2023.01.15~", role: .staff),
        StaffMember(name: "최예린", startDateText: "2025.06.07~", role: .staff),
    ]
    return StaffList_View(store: previewStore)
}
