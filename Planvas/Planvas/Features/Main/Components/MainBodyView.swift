//
//  MainBodyView.swift
//  Planvas
//
//  Created by 정서영 on 1/27/26.
//

import SwiftUI

// MARK: - 메인 바디 그룹
struct MainBodyView: View {
    @Bindable var viewModel: MainViewModel
    
    var body: some View {
        VStack {
            CalendarGroup(viewModel: viewModel)
            
            ToDoGroup(viewModel: viewModel)
            
            Rectangle()
                .frame(height: 10)
                .foregroundStyle(.line)
                .padding(.vertical, 22)
            
            ActivityGroup(viewModel: viewModel)
        }
    }
}

