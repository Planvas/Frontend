import SwiftUI

struct ReportView: View {
    @StateObject private var viewModel = ReportViewModel()
    
    var body: some View {
        ZStack {
            Color.primary1
                .ignoresSafeArea()
            
            VStack {
                if let reportData = viewModel.reportData {
                    HeaderSection(goal: reportData.goal)
                    
                    MainSection(
                        reportData: reportData,
                        statusImage: viewModel.statusImage,
                        themeColor: viewModel.themeColor,
                        comment: viewModel.comment
                    )
                } else {
                    ProgressView().tint(.white)
                }
            }
        }
        .task {
            viewModel.fetchReport(goalId: 12)
        }
    }
}

#Preview {
    ReportView()
}
