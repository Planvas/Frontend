import SwiftUI

struct LoginView: View {
    @State private var viewModel = LoginViewModel()
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
                    LoginSuccessView(viewModel: viewModel)
                        .environmentObject(container)
                }
            }
        }
        .onChange(of: viewModel.isLoginSuccess) { _, isSuccess in
            if isSuccess {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    container.rootRouter.root = .main
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(DIContainer())
}
