//
//  SearchRowButtonStyle.swift
//  Blendery
//
//  Created by 박성준 on 1/6/26.
//

import SwiftUI

struct SearchRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .background(configuration.isPressed ? Color.black.opacity(0.06) : Color.clear)
    }
}
