import SwiftUI

struct Login_Button: View {

    @ObservedObject var viewModel: LoginViewModel
    var onLoginSuccess: (() -> Void)?

    var body: some View {
        Button {
            Task {
                do {
                    await viewModel.login()
                    onLoginSuccess?()   // ⭐️ 여기서 RootView에게 알림
                }
            }
        } label: {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: .white)
                        )
                } else {
                    Text("로그인")
                        .fontWeight(.semibold)
                }
            }
            .frame(width: 300, height: 40)
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(30)
        }
        .disabled(viewModel.isLoading)
    }
}
