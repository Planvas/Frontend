//
//  CalendarFlowView.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI

struct CalendarFlowView: View {
//    @State private var router = NavigationRouter<CalendarRoute>()
    @Environment(NavigationRouter<OnboardingRoute>.self) private var onboardingRouter

    @State private var viewModel = CalendarViewModel()
    @State private var syncViewModel = CalendarSyncViewModel()
    @State private var isCalendarOnly = false

    var body: some View {
        Group {
            if isCalendarOnly {
                CalendarView(
                    onConnectGoogleCalendar: {
                        Task {
                            await syncViewModel.performGoogleCalendarConnect(onSuccess: {
                                await viewModel.refreshAfterGoogleConnect()
                            })
                        }
                    },
                    onFinish: {
                        // 온보딩 다음 단계로 이동
                        onboardingRouter.push(.interest)
                    }
                )
            } else {
                    CalendarSyncView(
                        viewModel: syncViewModel,
                        onDirectInput: { isCalendarOnly = true },
                        onImportSchedules: { schedules in
                            viewModel.importSchedules(schedules)
                            isCalendarOnly = true
                        }
                    )
            }
        }
        .environment(viewModel)
    }
}

#Preview {
    let router = NavigationRouter<OnboardingRoute>()

    CalendarFlowView()
        .environment(router)
}
