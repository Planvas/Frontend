//
//  ScheduleSelectionView.swift
//  Planvas
//
//  Created by 백지은 on 1/20/26.
//

import SwiftUI

struct ScheduleSelectionView: View {
    @StateObject private var viewModel = ScheduleSelectionViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var onImport: (([ImportableSchedule]) -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            // 제목, 부제목
            titleView
                .padding(.top, 45)
            
            // 일정 리스트
            scheduleListView
            
            // 하단 버튼
            importButtonView
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .onAppear { viewModel.loadSchedules() }
    }
   
    // MARK: - Title
    private var titleView: some View {
        VStack (alignment: .leading, spacing: 6){
            HStack {
                Text("어떤 일정을 가져올까요?")
                    .textStyle(.bold22)
                    .foregroundColor(.black1)
                Spacer()
            }
            HStack {
                Text("고정 일정으로 쓸 것만 선택해주세요")
                    .textStyle(.regular14)
                    .foregroundColor(.primary1)
                Spacer()
            }
        }
    }
   
    // MARK: - Schedule List
    private var scheduleListView: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .textStyle(.regular14)
                    .foregroundColor(.calRed)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.schedules) { schedule in
                            scheduleCardView(schedule: schedule)
                        }
                    }
                    .padding(1)
                }
            }
        }
    }
    
    // MARK: - Schedule Card
    private func scheduleCardView(schedule: ImportableSchedule) -> some View {
        Button {
            viewModel.toggleSelection(for: schedule)
        } label: {
            HStack(spacing: 12) {
                // 텍스트 영역
                VStack(alignment: .leading, spacing: 4) {
                    Text(schedule.title)
                        .textStyle(.semibold16)
                        .foregroundColor(.black1)
                    
                    Text(schedule.timeDescription)
                        .textStyle(.regular14)
                        .foregroundColor(.gray888)
                }
                
                Spacer()
                
                // 선택 아이콘
                if schedule.isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.primary1)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 24))
                        .foregroundColor(.ccc)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(schedule.isSelected ? .primary1 : .ccc,
                            lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Import Button
    private var importButtonView: some View {
        PrimaryButton(title: viewModel.importButtonTitle) {
            let selectedSchedules = viewModel.importSelectedSchedules()
            onImport?(selectedSchedules)
            dismiss()
        }
    }
}

#Preview {
    ScheduleSelectionView()
}
