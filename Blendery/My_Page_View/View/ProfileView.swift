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
    
    init(profile: UserProfile) {
        _viewModel = StateObject(
            wrappedValue: ProfileViewModel(profile: profile)
        )
    }
    
    var body: some View {
        VStack(spacing: 24) {
            profileCard
            infoCard
            
            Spacer()
            
            if viewModel.isPhotoEditSheetVisible {
                photoEditButtons
            }
        }
        .padding()
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
    }
    
    private var profileCard: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    if let image = viewModel.profileImage {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Circle()
                            .fill(
                                Color(
                                    red: 247/255,
                                    green: 247/255,
                                    blue: 247/255
                                )
                            )
                            .overlay(
                                Image("profileLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                            )
                    }
                }
                .frame(width: 72, height: 72)
                .clipShape(Circle())
                
                Button {
                    viewModel.openPhotoEditSheet()
                } label: {
                    cameraIcon
                }
                .offset(x: 2, y: 0)
            }
            
            VStack (spacing: 6){
                HStack(spacing: 6) {
                    Text(viewModel.profile.name)
                        .font(.system(size: 18, weight: .medium))
                    Image("pencil")
                    Spacer()
                }
                
                HStack {
                    Text("\(viewModel.profile.role)")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 25/255, green: 24/255, blue: 24/255, opacity: 1))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                    Text("\(viewModel.profile.joinedAt)")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 136/255, green: 136/255, blue: 136/255, opacity: 1))
                    Spacer()
                }
                
            }
            .padding(.horizontal, 5)
        }
        .padding(.vertical, 35)
        .padding(.horizontal, 20)
        .background(cardBackground)
    }
    
    private var infoCard: some View {
        VStack(spacing: 0) {
            infoRow(
                icon: Image("phone"),
                title: "Phone",
                value: viewModel.profile.phone
            )
            
            Divider()
                .padding(.leading, 23 + 24 + 8) // 아이콘 정렬 기준선
            
            infoRow(
                icon: Image("email"),
                title: "Email",
                value: viewModel.profile.email
            )
        }
        .padding(.vertical, 10)
        .background(cardBackground)
    }
    
    private func infoRow(
        icon: Image,
        title: String,
        value: String
    ) -> some View {
        HStack(alignment: .center, spacing: 8) {
            
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundStyle(
                        Color(red: 136/255, green: 136/255, blue: 136/255)
                    )
                
                Text(value)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 23)
        .padding(.vertical, 12)
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
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        Color(red: 224/255, green: 224/255, blue: 224/255),
                        lineWidth: 1
                    )
            )
            
            Button("닫기") {
                viewModel.closePhotoEditSheet()
            }
            .buttonStyle(ProfilePrimaryButtonStyle())
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        Color(red: 224/255, green: 224/255, blue: 224/255),
                        lineWidth: 1
                    )
            )
        }
    }


    private var cameraIcon: some View {
        Image(systemName: "camera.fill")
            .font(.system(size: 12))
            .foregroundColor(.white)
            .padding(6)
            .background(Circle().fill(Color.gray))
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            .shadow(color: Color.black.opacity(0.3), radius: 2)
    }
}

#Preview {
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
