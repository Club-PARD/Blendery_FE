// ===============================
//  StaffStore.swift
//  Blendery
// ===============================

import SwiftUI
import Combine

//  데이터 모델
//  - 매장 관리 화면에서 쓰는 직원(매니저/스태프) 단위 모델
struct StaffMember: Identifiable, Equatable {
    let id: UUID
    var name: String
    var startDateText: String
    var role: Role

    enum Role: String, CaseIterable, Identifiable {
        case manager = "매니저"
        case staff = "스태프"
        var id: String { rawValue }
    }

    init(
        id: UUID = UUID(),
        name: String,
        startDateText: String,
        role: Role
    ) {
        self.id = id
        self.name = name
        self.startDateText = startDateText
        self.role = role
    }
}

//  상태 저장소(ViewModel 역할)
//  - 지금은 서버 연동 없이 UI 중심으로만 동작(메모리 저장)
@MainActor
final class StaffStore: ObservableObject {

    //  상태 변수
    //  - 화면에서 표시할 전체 멤버 목록(매니저/스태프 합쳐서)
    @Published var members: [StaffMember] = [
        StaffMember(name: "이지수", startDateText: "2010.12.25~", role: .manager),
        StaffMember(name: "이지수", startDateText: "2010.12.25~", role: .staff),
        StaffMember(name: "이지수", startDateText: "2010.12.25~", role: .staff),
        StaffMember(name: "이지수", startDateText: "2010.12.25~", role: .staff),
    ]

    //  계산 변수
    //  - 역할별 필터
    var managers: [StaffMember] { members.filter { $0.role == .manager } }
    var staffs: [StaffMember] { members.filter { $0.role == .staff } }

    //  로직 함수
    //  - 멤버 업데이트(역할 변경 포함)
    func update(_ updated: StaffMember) {
        guard let idx = members.firstIndex(where: { $0.id == updated.id }) else { return }
        members[idx] = updated
    }

    //  로직 함수
    //  - 멤버 삭제
    func delete(_ member: StaffMember) {
        members.removeAll { $0.id == member.id }
    }

    //  로직 함수
    //  - 멤버 추가
    func add(name: String, startDateText: String, role: StaffMember.Role) {
        let newMember = StaffMember(name: name, startDateText: startDateText, role: role)
        members.append(newMember)
    }
}
