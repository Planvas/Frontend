import SwiftUI

struct ReportFlowView: View {
    @State private var router = NavigationRouter<ReportRoute>()
    let initialGoalId: Int
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ReportView(goalId: initialGoalId)
                .navigationDestination(for: ReportRoute.self) { route in
                    switch route {
                    case .report(let id):
                        ReportView(goalId: id)
                    }
                }
        }
        .environment(router)
    }
}

#Preview {
    ReportFlowView(initialGoalId: 12)
}
