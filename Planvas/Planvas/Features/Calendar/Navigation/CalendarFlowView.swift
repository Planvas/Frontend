//
//  CalendarFlowView.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI

struct CalendarFlowView: View {
    @Binding var selectedTab: Int
    var calendarTabTag: Int
    /// 온보딩 플로우에서만 전달. 메인 탭에서는 nil (이때 Environment에 OnboardingRoute 라우터 없어도 됨)
    var onFinishFromOnboarding: (() -> Void)? = nil
    
    /// 캘린더 연동 상태 변경 시 호출될 콜백
    var onSyncStateChange: ((Bool) -> Void)? = nil

    @State private var router = NavigationRouter<CalendarRoute>()
    @State private var viewModel = CalendarViewModel()
    @State private var syncViewModel = CalendarSyncViewModel()

    var body: some View {
        Group {
            CalendarView(
                onConnectGoogleCalendar: {
                    Task {
                        await syncViewModel.performGoogleCalendarConnect(onSuccess: {
                            await viewModel.refreshAfterGoogleConnect()
                        })
                    }
                },
                onFinish: onFinishFromOnboarding
            )
        }
        .environment(viewModel)
        .onChange(of: selectedTab) { _, newValue in
            if newValue == calendarTabTag {
                viewModel.moveToToday()
            }
        }
        // 뷰 진입 시 연동 상태 최신화 확인
        .task {
            syncViewModel.loadStatus()
        }
        // 연동 상태(isConnected)가 변하면 콜백 호출
        .onChange(of: syncViewModel.isConnected) { _, isConnected in
            onSyncStateChange?(isConnected)
        }
        .alert("연동 실패", isPresented: Binding(
            get: { syncViewModel.statusError != nil },
            set: { if !$0 { syncViewModel.statusError = nil } }
        )) {
            Button("확인") { syncViewModel.statusError = nil }
        } message: {
            Text(syncViewModel.statusError ?? "연동에 실패했습니다.")
        }
    }
}

#Preview {
    CalendarFlowView(selectedTab: .constant(1), calendarTabTag: 1)
}
