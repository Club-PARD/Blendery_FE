//
//  ProfileView.swift
//  Blendery
//
//  Created by 박영언 on 12/29/25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {

    @StateObject private var viewModel: ProfileViewModel
    @State private var showNameEdit = false
    @State private var showContactEdit = false
    @State private var contactType: ContactEditType?
    @State private var showLogoutPopup = false

    var onLogout: (() -> Void)?

    init(
        profile: UserProfile,
        onLogout: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: ProfileViewModel(profile: profile)
        )
        self.onLogout = onLogout
    }

    var body: some View {
        ZStack {
            // ✅ 배경색: rgba(242, 244, 246, 1)
            Color(red: 242/255, green: 244/255, blue: 246/255)
                .ignoresSafeArea()

            VStack {
                ZStack {
                    VStack(spacing: 16) {
                        ProfileCard(
                            viewModel: viewModel,
                            showEditButton: true,
                            showCameraButton: true,
                            onTapEditName: {
                                showNameEdit = true
                            },
                            nameView: nil
                        )

                        infoCard

                        HStack {
                            Spacer()
                            Button {
                                showLogoutPopup = true
                            } label: {
                                Text("로그아웃")
                                    .foregroundColor(.red)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .padding(.trailing, 10)
                        }

                        Spacer()

                        if viewModel.isPhotoEditSheetVisible {
                            photoEditButtons
                        }
                    }
                    .padding()
                    .disabled(viewModel.isPhotoEditSheetVisible)

                    if viewModel.isPhotoEditSheetVisible {
                        Color.black.opacity(0.001)
                            .ignoresSafeArea()
                            .onTapGesture {}
                    }

                    if viewModel.isPhotoEditSheetVisible {
                        VStack {
                            Spacer()
                            photoEditButtons
                        }
                        .padding(.bottom)
                    }

                    if showLogoutPopup {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .allowsHitTesting(true)

                        LogoutConfirmPopup(
                            onCancel: {
                                showLogoutPopup = false
                            },
                            onConfirm: {
                                showLogoutPopup = false
                                onLogout?()
                            }
                        )
                    }
                }
                .navigationTitle("프로필")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(showLogoutPopup)
                .interactiveDismissDisabled(showLogoutPopup)

                .photosPicker(
                    isPresented: $viewModel.showPhotoPicker,
                    selection: $viewModel.selectedItem,
                    matching: .images
                )
                .onChange(of: viewModel.selectedItem) { item in
                    Task {
                        await viewModel.handleSelectedPhoto(item)
                    }
                }
                .navigationDestination(isPresented: $showContactEdit) {
                    if let contactType {
                        ContactEditView(
                            viewModel: viewModel,
                            type: contactType
                        )
                    }
                }
                .navigationDestination(isPresented: $showNameEdit) {
                    NameEditView(viewModel: viewModel)
                }
            }
        }
    }

    private var infoCard: some View {
        VStack(spacing: 0) {
            ProfileInfoRow(
                icon: Image("phone"),
                title: "Phone",
                content: AnyView(Text(formattedPhone(viewModel.profile.phone))),
                onTap: {
                    contactType = .phone
                    showContactEdit = true
                }
            )

            Divider()
                .padding(.horizontal, 20)

            ProfileInfoRow(
                icon: Image("email"),
                title: "Email",
                content: AnyView(Text(viewModel.profile.email)),
                onTap: {
                    contactType = .email
                    showContactEdit = true
                }
            )
        }
        .padding(.vertical, 10)
        .background(cardBackground) // ✅ 테두리 제거된 카드 배경
    }

    private var photoEditButtons: some View {
        VStack(spacing: 12) {
            VStack(spacing: 0) {
                Button("앨범에서 선택") {
                    viewModel.selectPhoto()
                }
                .buttonStyle(ProfilePrimaryButtonStyle())

                if viewModel.profileImage != nil {
                    Divider()

                    Button("프로필 사진 삭제") {
                        Task { await viewModel.deletePhoto() }
                    }
                    .buttonStyle(ProfileDeleteButtonStyle())
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 247/255, green: 247/255, blue: 247/255))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                Color(red: 224/255, green: 224/255, blue: 224/255),
                                lineWidth: 1
                            )
                    )
            )

            Button("닫기") {
                viewModel.closePhotoEditSheet()
            }
            .buttonStyle(ProfilePrimaryButtonStyle())
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        Color(red: 224/255, green: 224/255, blue: 224/255),
                        lineWidth: 1
                    )
            )
        }
        .padding(.horizontal)
    }

    // ✅ infoCard 배경(테두리 제거 버전)
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white)
    }

    private func formattedPhone(_ number: String) -> String {
        let digits = number.filter { $0.isNumber }

        switch digits.count {
        case 0...3:
            return digits
        case 4...7:
            return "\(digits.prefix(3))-\(digits.dropFirst(3))"
        default:
            let first = digits.prefix(3)
            let middle = digits.dropFirst(3).prefix(4)
            let last = digits.dropFirst(7)
            return "\(first)-\(middle)-\(last)"
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(
            profile: UserProfile(
                name: "이지수",
                role: "매니저",
                joinedAt: "2010.12.25~",
                phone: "010-7335-1790",
                email: "l_oxo_l@handong.ac.kr"
            )
        )
    }
}
