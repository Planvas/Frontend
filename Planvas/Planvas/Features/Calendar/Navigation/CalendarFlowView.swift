//
//  CalendarFlowView.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI

struct CalendarFlowView: View {
    @State private var router = NavigationRouter<CalendarRoute>()
    @StateObject private var viewModel = CalendarViewModel()
    /// true이면 캘린더만 보이고, false이면 연동/직접 입력 화면
    @State private var isCalendarOnly = false
    
    var body: some View {
        Group {
            if isCalendarOnly {
                CalendarView()
            } else {
                NavigationStack(path: $router.path) {
                    CalendarSyncView(
                        onDirectInput: {
                            isCalendarOnly = true
                        },
                        onImportSchedules: { schedules in
                            viewModel.importSchedules(schedules)
                            isCalendarOnly = true
                        }
                    )
                }
            }
        }
        .environment(router)
        .environmentObject(viewModel)
    }
}

#Preview {
    CalendarFlowView()
}
