import SwiftUI

struct ProfileInfoRow: View {
    let icon: Image
    let title: String
    let content: AnyView
    let onTap: (() -> Void)?
    var showsChevron: Bool = true

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(
                        Color(red: 136/255, green: 136/255, blue: 136/255)
                    )

                content
            }
            .padding(.horizontal)

            Spacer()

            if showsChevron, let onTap {
                Button(action: onTap) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 23)
        .padding(.vertical, 12)
    }
}
