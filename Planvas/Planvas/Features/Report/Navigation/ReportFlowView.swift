//
//  ReportFlowView.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI

struct ReportFlowView: View {
    @State private var router = NavigationRouter<ReportRoute>()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ReportView()
                .navigationDestination(for: ReportRoute.self) { route in
                    switch route {
                    case .report:
                        ReportView()
                    }
                }
        }
        .environment(router)
    }
}

#Preview {
    ReportFlowView()
}
