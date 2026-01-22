//
//  CalendarSyncView.swift
//  Planvas
//
//  Created by 백지은 on 1/17/26.
//

// TODO : 캘린더 이미지 위에 유리? 같은 디자인? 네모? 그거 아직 안 넣었음 (근데 넣으면 흐려질텐데 애니메이션이 있나?)

import SwiftUI

struct CalendarSyncView: View {
    @StateObject private var viewModel = CalendarSyncViewModel()
    @State private var showScheduleSelection = false
    
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
                // 선택된 일정 처리
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Title
    private var titleView: some View {
        VStack(alignment: .leading, spacing: 15){
            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.calendarTitle)
                
                Text("고정 일정 불러오기")
                    .textStyle(.bold30)
                    .foregroundColor(.black1)
            }
            
            Text("고정 일정과 겹치지 않는 활동을\n따로 볼 수 있어요")
                .textStyle(.medium20)
                .foregroundColor(.black1)
        }
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
            
            // 직접 입력 버튼
            PrimaryButton(title: "직접 입력하고 관리할게요") {
                // TODO : 직접 입력 액션
            }
            
            Button{
                // TODO : 액션 추가하기
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
