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

    let profile: UserProfile
    @Published var profileImage: Image? = nil

    @Published var isPhotoEditSheetVisible = false
    @Published var showPhotoPicker = false
    @Published var selectedItem: PhotosPickerItem?

    private let service: ProfileService

    init(profile: UserProfile) {
        self.profile = profile
        self.service = ProfileService()
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
}


