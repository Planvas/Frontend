//
//  MainView.swift
//  Planvas
//
//  Created by 정서영 on 1/14/26.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        ScrollView{
            VStack{
                HeaderGroup
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - 메인 헤더 그룹
    private var HeaderGroup: some View {
        ZStack{
            Rectangle()
                .modifier(GradientModifier(startColor: .subPurple, endColor: .primary1))
            VStack(alignment: .leading){
                Image(.logo)
                    .resizable()
                    .frame(width: 180, height: 43)
                    .padding(.top, 60)
                    Text(viewModel.StateTitle)
                        .textStyle(.semibold30)
                        .padding(.bottom, 15)
                        .foregroundStyle(viewModel.goalSetting == .ing ?  .black1 : .fff)
                    Text(viewModel.StateDescription)
                    .textStyle(viewModel.goalSetting == .ing ? .semibold16 : .semibold20)
                        .foregroundStyle(.black1)
                
                if viewModel.goalSetting == .ing {
                    PresentGoalGroup
                } else {
                    HeaderButtonGroup
                }
            }
            .padding()
        }
    }
    
    // MARK: - 헤더 / 현재 세팅된 목표 그룹
    private var PresentGoalGroup: some View {
        VStack(alignment: .leading){
            Text("D-17")
                .textStyle(.medium20)
                .foregroundStyle(.fff)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(.primary1)
                )
                .padding(.top, 33)
            
            Text("시험 기간 전 갓생")
                .textStyle(.medium14)
                .foregroundStyle(.fff)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(.fff20)
                )
                .padding(.bottom, 14)
            
            Text("성장")
                .textStyle(.semibold20)
                .foregroundStyle(.black1)
            
            MainProgressView(
                goal: 60,
                progress: 40,
                startColor: .primary1,
                endColor: .primary2
            )
                .padding(.bottom, 10)
            
            Text("휴식")
                .textStyle(.semibold20)
                .foregroundStyle(.black1)
            
            MainProgressView(
                goal: 40,
                progress: 10,
                startColor: .gradprimary2,
                endColor: .primary1
            )
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - 헤더 / 버튼 그룹
    private var HeaderButtonGroup: some View {
        Button(action: {
            print(viewModel.goalSetting == .end ? "최종 리포트 확인하러 가기" : "목표 설정하러 가기")
        }){
            Text(viewModel.goalSetting == .end ? "최종 리포트 확인하러 가기" : "목표 설정하러 가기")
                .textStyle(.semibold20)
                .foregroundStyle(.black1)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(.subPurple)
                )
                .padding(.vertical)
        }
    }
}

#Preview {
    MainView()
}
