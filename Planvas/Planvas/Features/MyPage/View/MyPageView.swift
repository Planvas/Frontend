import SwiftUI
import Combine

struct MyPageView: View {
    @State private var viewModel = MyPageViewModel()
    @Environment(NavigationRouter<MyPageRoute>.self) var router
    
    var body: some View {
        ZStack {
            backgroundCircle
            
            VStack {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage).foregroundStyle(Color.red)
                } else if viewModel.goalData != nil {
                    ScrollView {
                        VStack(spacing: 40) {
                            ProfileView()
                            goalCardView(viewModel: viewModel)
                            DetailPageView()
                                .environment(router)
                        }
                    }
                    .scrollIndicators(.hidden)
                } else if viewModel.isLoading {
                    ProgressView().tint(.white)
                }
            }
        }
        .task {
            viewModel.fetchGoal()
        }
    }
}

// MARK: - Sub Views
extension MyPageView {
    private var backgroundCircle: some View {
        Circle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.primary1,
                        Color.primary1.opacity(0.9),
                        Color.gradprimary2]),
                    startPoint: .bottomTrailing,
                    endPoint: .leading)
            )
            .frame(width: 750, height: 750)
            .offset(y: -500)
    }
}
#Preview {
    return MyPageFlowView()
}
