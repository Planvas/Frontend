//
//  MainBodyView.swift
//  Planvas
//
//  Created by 정서영 on 1/27/26.
//

import SwiftUI

// MARK: - 메인 바디 그룹
struct MainBodyView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        VStack(alignment: .leading){
            // MARK: - 위클리 캘린더
            Text("이번 주")
                .textStyle(.semibold25)
                .padding(.top, 29)
                .padding(.leading, 29)
            
            VStack(alignment: .leading){
                Text(viewModel.monthText)
                    .textStyle(.semibold20)
                    .foregroundStyle(.black1)
                    .padding(.bottom)
                
                HStack(spacing: 16) {
                    ForEach(viewModel.weekDates, id: \.self) { date in
                        DateItem(
                            date: date,
                            isSelected: viewModel.selectedDate == date
                        )
                        .onTapGesture {
                            viewModel.selectedDate = date
                        }
                    }
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        LinearGradient(
                            colors: [.subPurple, .primary1],
                            startPoint: UnitPoint(x: -0.1, y: -0.1),
                            endPoint: UnitPoint(x: 0.2, y: 0.7)
                        ),
                        lineWidth: 1
                    )
            )
            .frame(maxWidth: .infinity)
        }
    }
}

