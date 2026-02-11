import SwiftUI

struct LoginView: View {
    @Environment(LoginViewModel.self) private var viewModel
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        ZStack {
            Image("loginBackground")
                .resizable()
                .ignoresSafeArea()
                .offset(y: -450)
            
            VStack(spacing: 40) {
                VStack(spacing: 5) {
                    Text("채워지는 만큼 목표에 가까워진다는 확신")
                        .textStyle(.medium18)
                        .foregroundStyle(Color.primary1)
                    Text("플랜바스가 함께 만들어 드릴게요")
                        .textStyle(.medium18)
                }
                
                Image("startImage")
                    .resizable()
                    .frame(width: 135, height: 135)
                    .padding()
                
                VStack {
                    Image("loginLogo")
                        .padding()
                    Group {
                        Text("내가 그리는 모습 그대로,")
                        Text("일상을 채워나가는 밸런스 플래너")
                    }
                    .textStyle(.semibold20)
                }
                
                PlanvasButton(
                    title: "Google로 시작하기",
                    isDisabled: false,
                    action: {
                        viewModel.GoogleLogin()
                    })
                .padding(.top, 30)
                .padding(.horizontal)
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
                    container.rootRouter.root = .onboarding
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(LoginViewModel())
        .environmentObject(DIContainer())
}
