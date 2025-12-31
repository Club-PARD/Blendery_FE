//
//  ContactEditType.swift
//  Blendery
//
//  Created by 박영언 on 12/29/25.
//
import UIKit

enum ContactEditType: Identifiable {
    case phone
    case email

    var id: Self { self }


    static let navigationTitle = "프로필 수정"

    /// 타입별 placeholder
    var placeholder: String {
        switch self {
        case .phone:
            return "Phone"
        case .email:
            return "Email"
        }
    }

    /// 타입별 키보드
    var keyboard: UIKeyboardType {
        switch self {
        case .phone:
            return .numberPad
        case .email:
            return .emailAddress
        }
    }
}

