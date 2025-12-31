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
                            formattedPlaceholder,
                            text: $text
                        )
                        .id(type)
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
                        .onChange(of: text) { newValue in
                            guard type == .email else { return }
                            let lowercased = newValue.lowercased()
                            if lowercased != newValue {
                                text = lowercased
                            }
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
                guard isButtonEnabled else { return }

                if text != currentValue {
                    applyChange()
                }
                dismiss()
            } label: {
                Text("완료")
                    .font(.system(size: 15))
                    .foregroundColor(isButtonEnabled ? .black : .gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                isButtonEnabled
                                ? Color(red: 247/255, green: 247/255, blue: 247/255)
                                : Color(red: 235/255, green: 235/255, blue: 235/255)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        Color(red: 224/255, green: 224/255, blue: 224/255),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .opacity(isButtonEnabled ? 1.0 : 0.6)
            }
            .disabled(!isButtonEnabled)
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
        .onAppear {
            text = ""

            DispatchQueue.main.async {
                isFocused = true
            }
            
            #if DEBUG
            if !ProcessInfo.processInfo.environment.keys.contains("XCODE_RUNNING_FOR_PREVIEWS") {
                DispatchQueue.main.async {
                    isFocused = true
                }
            }
            #else
            DispatchQueue.main.async {
                isFocused = true
            }
            #endif
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
    
    private var formattedPlaceholder: String {
        switch type {
        case .phone:
            return formatPhoneNumber(currentValue)
        case .email:
            return currentValue
        }
    }

    private var isButtonEnabled: Bool {
        switch type {
        case .phone:
            return isValidPhoneNumber
        case .email:
            return isValidEmail
        }
    }
    
    private var isValidEmail: Bool {
        let emailRegex =
        #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        
        return NSPredicate(format: "SELF MATCHES %@", emailRegex)
            .evaluate(with: text)
    }
}


#Preview {
    let mockProfile = UserProfile(
        name: "이지수",
        role: "매니저",
        joinedAt: "2010.12.25~",
        phone: "01073351790",
        email: "l_oxo_l@handong.ac.kr"
    )

    let mockViewModel = ProfileViewModel(profile: mockProfile)

    NavigationStack {
        ContactEditView(viewModel: mockViewModel, type: .email)
    }
}

