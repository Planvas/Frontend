import SwiftUI
import Combine

struct LoginSuccessView: View {
    @EnvironmentObject var container: DIContainer
    @Environment(LoginViewModel.self) var viewModel

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.gradprimary1.opacity(0.2), Color.white]),
                startPoint: .bottom,
                endPoint: .top)
            .ignoresSafeArea()

            VStack {
                Image("loginImage")
                    .resizable()
                    .frame(width: 174, height: 213)
                    .padding(.vertical, 50)

                VStack {
                    Text("로그인 완료!")
                        .foregroundStyle(Color.gray444)
                        .textStyle(.medium20)
                        .padding()
                    Group {
                        Text("\(viewModel.userName)님,")
                        Text("환영해요!")
                    }
                    .textStyle(.bold30)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            container.appState.isLoggedIn = true
            let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: OnboardingKeys.hasCompletedOnboarding)
            let hasActiveGoal = UserDefaults.standard.bool(forKey: OnboardingKeys.hasActiveGoal)
            if hasCompletedOnboarding && hasActiveGoal {
                container.rootRouter.root = .main
            } else {
                // TODO: 임시로 주석처리, 다음 버튼 완성되면 아래 main 지우고 해당 줄 주석 해제해주세요!
                // container.rootRouter.root = .onboarding  
                container.rootRouter.root = .main
            }
        }
    }
}
