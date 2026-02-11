import SwiftUI

struct LoginView: View {
    @Environment(LoginViewModel.self) private var viewModel
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .frame(width: 404, height: 404)
                .offset(y: -80)
            
            VStack {
                Spacer()
                    .frame(height: 100)
                
                Image("startImage")
                    .resizable()
                    .frame(width: 185, height: 185)
                
                Spacer()
                    .frame(height: 40)
                
                VStack {
                    Text("Planvas")
                        .textStyle(.extrabold45)
                        .linearGradient(startColor: .gradprimary1, endColor: .gradprimary2)
                        .padding(.vertical, 5)
                    Group {
                        Text("내가 그리는 모습 그대로,")
                        Text("일상을 채워나가는 밸런스 플래너")
                    }
                    .textStyle(.semibold20)
                }
                
                Spacer()
                    .frame(height: 70)
                
                PlanvasButton(
                    title: "Google로 시작하기",
                    isDisabled: false,
                    action: {
                        viewModel.GoogleLogin()
                    })
                .padding()
                .fullScreenCover(isPresented: Binding(
                    get: { viewModel.isLoginSuccess },
                    set: { viewModel.isLoginSuccess = $0 }
                )) {
                    LoginSuccessView()
                        .environmentObject(container)
                }
            }
        }
        .onChange(of: viewModel.isLoginSuccess) { _, isSuccess in
            guard isSuccess else { return }
            // 로그인 성공 후 2초 뒤 온보딩·목표 상태에 따라 자동 라우팅 (LoginSuccessView 탭과 동일 로직)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                container.appState.isLoggedIn = true
                let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: OnboardingKeys.hasCompletedOnboarding)
                let hasActiveGoal = UserDefaults.standard.bool(forKey: OnboardingKeys.hasActiveGoal)
                if hasCompletedOnboarding && hasActiveGoal {
                    container.rootRouter.root = .main
                } else {
                    // TODO: 임시로 주석처리, 다음 버튼 완성되면 아래 main 지우고 해당 줄 주석 해제해주세요!
//                    container.rootRouter.root = .main
                    container.rootRouter.root = .onboarding
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(DIContainer())
}
