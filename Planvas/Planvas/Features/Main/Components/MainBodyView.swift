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
        VStack {
            CalendarGroup(monthText: viewModel.monthText, weekDates: viewModel.weekDates, selectedDate: $viewModel.selectedDate)
        }
    }
}

