import SwiftUI

struct OnboardingAnimationView: View {
    @State private var didSetup = false
    @State private var baseSize: CGSize = .zero
    @State private var baseInsets: EdgeInsets = .init()

    @State private var logoY: CGFloat = 0
    @State private var showLoginUI = false

    private let logoSize: CGFloat = 120
    private let gapToField: CGFloat = 120

    //  끝 위치(로고 최종 위치)용: 그대로 유지
    private let logoOnlyOffset: CGFloat = 360

    //  로고+로그인 UI 같이 내리기(배경 제외): 그대로 유지
    private let wholeYOffset: CGFloat = 60

    //  여기만 조절하면 "로고 시작점"만 위/아래로 움직임 (끝점/로그인 UI는 그대로)
    private let logoStartOffset: CGFloat = 325
    //  ↑ 지금 시작점이 "아래"면 -로(예: -60, -120)
    //  ↑ 지금 시작점이 "위"면 +로(예: +60)

    var body: some View {
        GeometryReader { geo in
            let width  = (baseSize == .zero) ? geo.size.width  : baseSize.width
            let height = (baseSize == .zero) ? geo.size.height : baseSize.height
            let insets = (baseSize == .zero) ? geo.safeAreaInsets : baseInsets

            let safeCenterY = (height - insets.top - insets.bottom) / 2 + insets.top
            let loginBlockY = (height - insets.top - insets.bottom) * 0.45 + insets.top
            let logoTargetY = loginBlockY - gapToField - (logoSize / 2)

            //  시작점은 별도 오프셋로만 조절
            let logoStartY = safeCenterY + logoStartOffset

            //  끝점은 기존 로직 그대로(로고만 아래로 내린 위치)
            let logoEndY   = logoTargetY + logoOnlyOffset

            ZStack {
                Color.black.ignoresSafeArea()

                ZStack {
                    LoginView()
                        .frame(width: width)
                        .position(x: width / 2, y: loginBlockY)
                        .opacity(showLoginUI ? 1 : 0)
                        .animation(.easeInOut(duration: 0.25), value: showLoginUI)
                        .allowsHitTesting(showLoginUI)

                    Image("로고")
                        .resizable()
                        .scaledToFit()
                        .frame(width: logoSize, height: logoSize)
                        .position(x: width / 2, y: logoY)
                }
                .offset(y: wholeYOffset)
            }
            .ignoresSafeArea(.keyboard, edges: .all)
            .onAppear {
                guard !didSetup else { return }
                didSetup = true

                baseSize = geo.size
                baseInsets = geo.safeAreaInsets

                logoY = logoStartY

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        logoY = logoEndY
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showLoginUI = true
                }
            }
        }
    }
}

#Preview("Onboarding - in NavigationStack") {
    NavigationStack {
        OnboardingAnimationView()
            .navigationBarHidden(true)
    }
}
