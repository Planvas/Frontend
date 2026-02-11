import SwiftUI

struct LoginView: View {
    @Environment(LoginViewModel.self) var viewModel
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
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
            }
        }
        .onAppear {
            viewModel.isLoginSuccess = false
        }
        .fullScreenCover(isPresented: $viewModel.isLoginSuccess) {
            LoginSuccessView()
        }
    }
}

#Preview {
    LoginView()
        .environment(LoginViewModel())
        .environmentObject(DIContainer())
}
