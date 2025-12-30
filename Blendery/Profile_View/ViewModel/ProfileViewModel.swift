//
//  MyPageViewModel.swift
//  Blendery
//
//  Created by 박영언 on 12/29/25.
//

//
//  MyPageView.swift
//  Blendery
//
//  Created by 박영언 on 12/29/25.
//

// Profile/ViewModel/ProfileViewModel.swift
import SwiftUI
import PhotosUI
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var profile: UserProfile
    @Published var profileImage: Image? = nil

    @Published var isPhotoEditSheetVisible = false
    @Published var showPhotoPicker = false
    @Published var selectedItem: PhotosPickerItem?

    private let service: ProfileService

    init(profile: UserProfile) {
        self.profile = profile
        self.service = ProfileService()
    }
    
    func updateName(_ newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard trimmed != profile.name else { return }

        profile = UserProfile(
            name: trimmed,
            role: profile.role,
            joinedAt: profile.joinedAt,
            phone: profile.phone,
            email: profile.email
        )
    }
    
    func updatePhone(_ newPhone: String) {
        let trimmed = newPhone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard trimmed != profile.phone else { return }

        profile = UserProfile(
            name: profile.name,
            role: profile.role,
            joinedAt: profile.joinedAt,
            phone: trimmed,
            email: profile.email
        )

        // TODO: 서버 연동 시 여기서 API 호출
    }

    func updateEmail(_ newEmail: String) {
        let trimmed = newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard trimmed != profile.email else { return }

        profile = UserProfile(
            name: profile.name,
            role: profile.role,
            joinedAt: profile.joinedAt,
            phone: profile.phone,
            email: trimmed
        )

        // TODO: 서버 연동 시 여기서 API 호출
    }


    func openPhotoEditSheet() {
        isPhotoEditSheetVisible = true
    }

    func closePhotoEditSheet() {
        isPhotoEditSheetVisible = false
    }

    func selectPhoto() {
        showPhotoPicker = true
    }

    func deletePhoto() async {
        profileImage = nil
        isPhotoEditSheetVisible = false
        try? await service.deleteProfileImage()
    }

    func handleSelectedPhoto(_ item: PhotosPickerItem?) async {
        guard
            let data = try? await item?.loadTransferable(type: Data.self),
            let uiImage = UIImage(data: data)
        else { return }

        profileImage = Image(uiImage: uiImage)

        isPhotoEditSheetVisible = false
        showPhotoPicker = false

        try? await service.uploadProfileImage(data)
    }
    
    func cancelProfileImageEdit() {
        isPhotoEditSheetVisible = false
        showPhotoPicker = false
    }
}


