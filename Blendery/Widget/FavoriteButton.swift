import SwiftUI

struct FavoriteButton: View {

    @Binding var isFavorite: Bool
    let onToggle: () -> Void

    var body: some View {
        Button {
            onToggle()
        } label: {
            Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                .resizable()
                .frame(width: 15.2, height: 18.25)
                .foregroundColor(.red)
        }
        .buttonStyle(.plain)
    }
}
