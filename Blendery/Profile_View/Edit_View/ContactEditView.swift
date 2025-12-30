import SwiftUI

struct ContactEditView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let type: ContactEditType

    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 16) {

            VStack(spacing: 0) {
                ProfileInfoRow(
                    icon: icon,
                    title: title,
                    content: AnyView(
                        TextField(
                            currentValue,
                            text: $text
                        )
                        .font(.system(size: 15))
                        .keyboardType(type.keyboard)
                        .focused($isFocused)
                        .textContentType(.none)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.none)
                        .onChange(of: text) { newValue in
                            guard type == .phone else { return }
                            text = formatPhoneNumber(newValue)
                        }
                    ),
                    onTap: nil,
                    showsChevron: false
                )
                .padding(.vertical, 10)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            )
            .padding(.top, 16)

            Button {
                guard !text.isEmpty else {
                    dismiss()
                    return
                }

                if text != currentValue {
                    applyChange()
                }

                dismiss()
            } label: {
                Text("완료")
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 247/255, green: 247/255, blue: 247/255))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        Color(red: 224/255, green: 224/255, blue: 224/255),
                                        lineWidth: 1
                                    )
                            )
                    )
            }
            .onChange(of: text) { newValue in
                guard type == .phone else { return }
                text = formatPhoneNumber(newValue)
            }
            .disabled(
                type == .phone
                ? !isValidPhoneNumber
                : text.isEmpty
            )

            Spacer()
        }
        .padding()
        .navigationTitle(ContactEditType.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            text = ""
            try? await Task.sleep(nanoseconds: 300_000_000)
            isFocused = true
        }
    }

    // MARK: - Computed Properties

    private var title: String {
        type == .phone ? "Phone" : "Email"
    }

    private var icon: Image {
        type == .phone ? Image("phone") : Image("email")
    }

    private var currentValue: String {
        type == .phone
        ? viewModel.profile.phone
        : viewModel.profile.email
    }

    // MARK: - Actions

    private func applyChange() {
        switch type {
        case .phone:
            let pureNumber = text.filter { $0.isNumber }
            viewModel.updatePhone(pureNumber)
        case .email:
            viewModel.updateEmail(text)
        }
    }

    
    private func formatPhoneNumber(_ input: String) -> String {
        let numbers = input.filter { $0.isNumber }

        let limited = String(numbers.prefix(11))

        switch limited.count {
        case 0...3:
            return limited
        case 4...7:
            return "\(limited.prefix(3))-\(limited.dropFirst(3))"
        default:
            let first = limited.prefix(3)
            let middle = limited.dropFirst(3).prefix(4)
            let last = limited.dropFirst(7)
            return "\(first)-\(middle)-\(last)"
        }
    }
    
    private var isValidPhoneNumber: Bool {
        let numbers = text.filter { $0.isNumber }
        return numbers.count == 11
    }

}


#Preview {
    let mockProfile = UserProfile(
        name: "이지수",
        role: "매니저",
        joinedAt: "2010.12.25~",
        phone: "010-7335-1790",
        email: "l_oxo_l@handong.ac.kr"
    )

    let mockViewModel = ProfileViewModel(profile: mockProfile)

    NavigationStack {
        ContactEditView(viewModel: mockViewModel, type: .phone)
    }
}
