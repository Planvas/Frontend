//
//  CalendarSyncView.swift
//  Planvas
//
//  Created by 백지은 on 1/17/26.
//

import SwiftUI

struct CalendarSyncView: View {
    var viewModel: CalendarSyncViewModel

    var onDirectInput: (() -> Void)?
    var onImportSchedules: (([ImportableSchedule]) -> Void)?

    private var scheduleSelectionBinding: Binding<Bool> {
        Binding(
            get: { viewModel.shouldOpenScheduleSelection },
            set: { if !$0 { viewModel.dismissScheduleSelection() } }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            titleView
            Spacer()
            calendarIconView
            Spacer()
            bottomButtonsView
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .onAppear {
            viewModel.loadStatus()
        }
        .sheet(isPresented: scheduleSelectionBinding) {
            ScheduleSelectionView { selectedSchedules in
                viewModel.dismissScheduleSelection()
                onImportSchedules?(selectedSchedules)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Title
    private var titleView: some View {
        VStack(alignment: .leading, spacing: 15){
            VStack(alignment: .leading, spacing: 3) {
                Text(calendarTitleAttributed)
                
                Text("고정 일정 불러오기")
                    .textStyle(.bold30)
                    .foregroundColor(.black1)
            }
            
            Text("고정 일정과 겹치지 않는 활동을\n따로 볼 수 있어요")
                .textStyle(.medium20)
                .foregroundColor(.black1)
        }
    }
    
    /// 캘린더 타이틀 AttributedString 생성
    private var calendarTitleAttributed: AttributedString {
        var attributed = AttributedString(viewModel.calendarTitleText)
        
        if let range = attributed.range(of: viewModel.highlightedText) {
            attributed[range].foregroundColor = .primary1
            attributed[range].font = TextStyle.bold30.swiftUIFont
        }
        
        if let range = attributed.range(of: "으로") {
            attributed[range].foregroundColor = .black1
            attributed[range].font = TextStyle.bold30.swiftUIFont
        }
        
        return attributed
    }

   
    // MARK: - Calendar Icon
    private var calendarIconView: some View {
        ZStack {
            VStack(alignment: .center, spacing: 20){
                Image(.googleCalendar)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 150)
                
                Text("쉽고 빠른 일정 관리")
                    .textStyle(.medium16)
                    .foregroundColor(.black1)
            }
        }
        .frame(maxWidth: .infinity)
    }
        
    // MARK: - Bottom Buttons
    private var bottomButtonsView: some View {
        VStack(spacing: 12) {
            // Google 캘린더 연동: 구글 로그인 → serverAuthCode → POST connect → 성공 시 일정 선택 시트
            SecondaryButton(title: "Google 캘린더 연동") {
                viewModel.performGoogleCalendarConnect()
            }
            .disabled(viewModel.isConnecting)
            
            // 직접 입력 버튼 → 캘린더 화면으로 전환
            PrimaryButton(title: "직접 입력하고 관리할게요") {
                onDirectInput?()
            }
            
            Button{
                // TODO: 액션 추가하기... 근데 이거 버튼이 아닌가?봐?...? 일단 놔두고 아니면 text로 빼기
            } label: {
                Text("언제든 연동할 수 있어요")
                    .textStyle(.regular14)
                    .foregroundColor(.gray888)
                    .padding(.top, 4)
            }
        }
    }
}

#Preview {
    CalendarSyncView(viewModel: CalendarSyncViewModel())
}
