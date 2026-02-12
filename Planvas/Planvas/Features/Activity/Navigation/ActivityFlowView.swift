//
//  ActivityFlowView.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI

struct ActivityFlowView: View {
    @State private var router = NavigationRouter<ActivityRoute>()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ActivityListView()
                .navigationDestination(for: ActivityRoute.self) { route in
                    switch route {
                    case .activityList:
                        ActivityListView()
                    }
                }
        }
        .environment(router)
    }
}

#Preview {
    ActivityFlowView()
}
