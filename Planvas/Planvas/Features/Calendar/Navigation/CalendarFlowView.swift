//
//  CalendarFlowView.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI

struct CalendarFlowView: View {
    @State private var router = NavigationRouter<CalendarRoute>()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            CalendarView()
                .navigationDestination(for: CalendarRoute.self) { route in
                    switch route {
                    case .calendar:
                        CalendarView()
                    }
                }
        }
        .environment(router)
    }
}

#Preview {
    CalendarFlowView()
}
