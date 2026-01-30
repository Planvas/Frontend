//
//  CalendarSyncView.swift
//  Planvas
//
//  Created by 백지은 on 1/17/26.
//

import SwiftUI

struct CalendarSyncView: View {
    @StateObject private var viewModel = CalendarSyncViewModel()
    @State private var showScheduleSelection = false
    
    /// 직접 입력 시 캘린더 화면으로 이동
    var onDirectInput: (() -> Void)?
    /// 가져오기 완료 시 선택 일정 전달 후 캘린더 화면으로 이동 (API 연동 시 서버 전달은 호출측에서 처리?)
    var onImportSchedules: (([ImportableSchedule]) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            // 제목 및 설명
            titleView
            
            Spacer()
            
            // 캘린더 아이콘
            calendarIconView
                       
            Spacer()
            
            // 하단 버튼들
            bottomButtonsView
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .sheet(isPresented: $showScheduleSelection) {
            ScheduleSelectionView { selectedSchedules in
                // 시트 닫은 뒤 선택 일정 전달하고 캘린더로 이동
                showScheduleSelection = false
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
            // Google 캘린더 연동 버튼
            SecondaryButton(title: "Google 캘린더 연동") {
                showScheduleSelection = true
            }
            
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
    CalendarSyncView()
}
