import SwiftUI

struct ReportView: View {
    let goalId: Int
    @StateObject private var viewModel = ReportViewModel()
    
    var body: some View {
        ZStack {
            Color.primary1
                .ignoresSafeArea()
            
            VStack {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(Color.red)
                } else if let reportData = viewModel.reportData {
                    let startDate = viewModel.formatDate(dateString: reportData.goal.startDate)
                    let endDate = viewModel.formatDate(dateString: reportData.goal.endDate)
                    HeaderSection(
                        title: reportData.goal.title,
                        dateRange: "\(startDate)~\(endDate)")
                    
                    MainSection(
                        reportData: reportData,
                        statusImage: viewModel.statusImage,
                        themeColor: viewModel.themeColor,
                        comment: viewModel.comment
                    )
                } else if viewModel.isLoading {
                    ProgressView().tint(.white)
                }
            }
        }
        .task {
            viewModel.fetchReport(goalId: goalId)
        }
    }
}

#Preview {
    ReportView(goalId: 12)
        .environment(NavigationRouter<MyPageRoute>())
        .environment(NavigationRouter<MainRoute>())
}
