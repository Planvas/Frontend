//
//  MainView.swift
//  Planvas
//
//  Created by 정서영 on 1/14/26.
//

import SwiftUI

struct MainView: View {
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
                Group{
                    Text("지수님, 반가워요!")
                        .textStyle(.semibold30)
                        .padding(.bottom)
                    Text("바라는 모습대로 만든 균형에 맞춰 일상을 채워보세요  그 시도만으로도 확실한 성취입니다")
                        .textStyle(.semibold16)
                }
                .foregroundStyle(.black1)
                
                PresentGoalGroup
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
            
            Text("시험 기간 전 갓생")
                .textStyle(.medium14)
                .foregroundStyle(.fff)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(.fff20)
                )
            
            Text("성장")
                .textStyle(.semibold20)
                .foregroundStyle(.black1)
            
            MainProgressView(
                goal: 60,
                progress: 40,
                startColor: .primary1,
                endColor: .primary2
            )
                .padding(.bottom, 35)
            
            Text("휴식")
                .textStyle(.semibold20)
                .foregroundStyle(.black1)
            
            MainProgressView(
                goal: 40,
                progress: 10,
                startColor: .gradprimary2,
                endColor: .primary1
            )
        }
    }
    

}

#Preview {
    MainView()
}
