//
//  ProfileEditButtonStyle.swift
//  Blendery
//
//  Created by 박영언 on 12/29/25.
//
import SwiftUI

struct ProfilePrimaryButtonStyle: ButtonStyle {

    var foreground: Color = .black
    var background: Color = Color(red: 247/255, green: 247/255, blue: 247/255)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15))
            .foregroundColor(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(background)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

struct ProfileDeleteButtonStyle: ButtonStyle {

    var foreground: Color = Color(red: 226/255, green: 49/255, blue: 0/255)
    var background: Color = Color(red: 247/255, green: 247/255, blue: 247/255)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15))
            .foregroundColor(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(background)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}
