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
    @StateObject private var syncViewModel = CalendarSyncViewModel()
    @State private var isCalendarOnly = false
    @State private var showLoginSheet = false

    var body: some View {
        Group {
            if isCalendarOnly {
                CalendarView()
            } else {
                NavigationStack(path: $router.path) {
                    CalendarSyncView(
                        viewModel: syncViewModel,
                        onDirectInput: { isCalendarOnly = true },
                        onImportSchedules: { schedules in
                            viewModel.importSchedules(schedules)
                            isCalendarOnly = true
                        },
                        onNeedGoogleLogin: { showLoginSheet = true }
                    )
                }
            }
        }
        .environment(router)
        .environmentObject(viewModel)
        .sheet(isPresented: $showLoginSheet, onDismiss: {
            syncViewModel.loadStatus()
        }) {
            LoginView()
        }
    }
}

#Preview {
    CalendarFlowView()
}
