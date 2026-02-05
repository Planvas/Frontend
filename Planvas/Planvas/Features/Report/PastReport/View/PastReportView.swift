import SwiftUI
import Foundation

struct PastReportView: View {
    @StateObject var viewModel = PastReportViewModel()
    @Environment(NavigationRouter<MyPageRoute>.self) var myPageRouter
    
    private let currentyear = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                ForEach(viewModel.sortedYears, id: \.self) { year in
                    MenuSection("\(year)년") {
                        if let reports = viewModel.reportsByYear[year] {
                            ReportSectionView(reports: reports) { goalId in
                                myPageRouter.push(.reportPage(goalId: goalId))
                            }
                        }
                    }
                }
                
                if !viewModel.sortedYears.contains(self.currentyear) {
                    MenuSection("\(self.currentyear)년") {
                        EmptyReportView()
                    }
                    .padding(.horizontal, 20)
                }
            }
            .task {
                viewModel.fetchPastReport()
            }
            .navigationTitle("지난 시즌 리포트")
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    PastReportView()
        .environment(NavigationRouter<MyPageRoute>())
}
