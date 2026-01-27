//
//  ReportFlowView.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI

struct ReportFlowView: View {
    @State private var router = NavigationRouter<ReportRoute>()
    
    // TODO: - 서버 연동 시 실제 goalID를 주입받도록 수정
    var body: some View {
        NavigationStack(path: $router.path) {
            ReportView(goalId: 12)
                .navigationDestination(for: ReportRoute.self) { route in
                    switch route {
                    case .report:
                        ReportView(goalId: 12)
                    }
                }
        }
        .environment(router)
    }
}

#Preview {
    ReportFlowView()
}
