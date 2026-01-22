import SwiftUI

struct LoginSuccessView: View {
    @EnvironmentObject var viewModel: LoginViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple1.opacity(0.2), Color.white]),
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
                        .foregroundStyle(Color.gray2)
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
    }
}
