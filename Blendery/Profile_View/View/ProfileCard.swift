import SwiftUI

struct ProfileCard: View {

    @ObservedObject var viewModel: ProfileViewModel
    let showEditButton: Bool
    let showCameraButton: Bool
    let onTapEditName: (() -> Void)?
    let nameView: AnyView?

    var body: some View {
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
                
                if showCameraButton {
                    Button {
                        viewModel.openPhotoEditSheet()
                    } label: {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Circle().fill(Color.gray))
                    }
                    .offset(x: 2, y: 0)
                }
            }

            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    if let nameView {
                        nameView
                    } else {
                        Text(viewModel.profile.name)
                            .font(.system(size: 18, weight: .medium))
                    }

                    if showEditButton, let onTapEditName {
                        Button(action: onTapEditName) {
                            Image("pencil")
                        }
                    }
                    Spacer()
                }

                HStack {
                    Text(viewModel.profile.role)
                        .font(.system(size: 12))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )

                    Text(viewModel.profile.joinedAt)
                        .font(.system(size: 12))
                        .foregroundColor(
                            Color(
                                red: 136/255,
                                green: 136/255,
                                blue: 136/255
                            )
                        )

                    Spacer()
                }
            }
            .padding(.horizontal, 5)
        }
        .padding(.vertical, 35)
        .padding(.horizontal, 20)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            .shadow(color: Color.black.opacity(0.3), radius: 2)
    }
}
