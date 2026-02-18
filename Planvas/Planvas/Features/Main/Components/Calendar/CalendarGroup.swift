//
//  CalendarGroup.swift
//  Planvas
//
//  Created by 정서영 on 1/28/26.
//

import SwiftUI

// MARK: - 바디 / 캘린더 그룹
struct CalendarGroup: View {
    @Bindable var viewModel: MainViewModel
    
    var body: some View {
        VStack(alignment: .leading){
            Text("이번 주")
                .textStyle(.semibold25)
                .padding(.top, 29)
                .padding(.leading, 20)
            
            VStack(alignment: .leading, spacing: 0){
                HStack(alignment: .bottom){
                    Text(viewModel.monthText)
                        .textStyle(.semibold20)
                        .foregroundStyle(.black1)
                        .padding(.bottom)
                    
                    Text(viewModel.yearText)
                        .textStyle(.semibold14)
                        .foregroundStyle(.black1)
                        .padding(.bottom)
                }
                .padding(.leading, 5)
                
                HStack(spacing: 0){
                    ForEach(viewModel.weekDates, id: \.self) { date in
                        DateItem(
                            date: date,
                            isSelected: viewModel.selectedDate == date,
                            selectedDate: $viewModel.selectedDate,
                            weeklyBarSchedules: viewModel.weeklyBarSchedules,
                            recurringSchedules: viewModel.allSchedules.filter { $0.recurrenceRule != nil }
                        )
                    }
                }
            }
            .padding(.horizontal, 7)
            .padding(.top, 14)
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(.primary50, lineWidth: 1)
            )
            .padding(.horizontal)
        }
    }
}
