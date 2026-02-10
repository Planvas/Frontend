import SwiftUI
import Combine

struct LoginSuccessView: View {
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var viewModel: LoginViewModel
    
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
//            viewModel.rootRouter?.root = .main
//            viewModel.rootRouter?.objectWillChange.send()
            let hasCompletedOnboarding =
                UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
            let hasActiveGoal =
                UserDefaults.standard.bool(forKey: "hasActiveGoal")

            // 온보딩을 이미 완료했고, 현재 활성화된 목표가 있는 경우 → 바로 메인 화면으로 이동
            if hasCompletedOnboarding && hasActiveGoal {
                container.rootRouter.root = .main
            } else {
                // 온보딩을 완료하지 않았거나 목표가 없는 경우 → 목표 설정 온보딩으로 이동
                container.rootRouter.root = .onboarding
            }
        }
    }
}
