//
//  MainHeaderView.swift
//  Planvas
//
//  Created by 정서영 on 1/26/26.
//

import SwiftUI

// MARK: - 메인 헤더 그룹
struct MainHeaderView: View {
    @Bindable var viewModel: MainViewModel
    @State private var animate = false
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Image(.planvasLogo)
                    .resizable()
                    .frame(width: 98, height: 23)
                    .padding(.top, 60)
                
                Text(viewModel.stateTitle)
                    .lineLimit(nil)
                    .textStyle(.semibold30)
                    .foregroundStyle( .black1)
                    .padding(.top, viewModel.goalSetting == .ACTIVE ? 40 : 0)
                    .offset(y: viewModel.goalSetting == .ACTIVE ? 0 : 30)
                
                HStack{
                    Group{
                        Text(viewModel.dDay)
                            .textStyle(.medium14)
                            .foregroundStyle(.fff)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .foregroundStyle(.primary1)
                            )
                        
                        Text(viewModel.goalTitle)
                            .textStyle(.medium14)
                            .foregroundStyle(.fff)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .foregroundStyle(.primary50)
                            )
                    }
                    .opacity(viewModel.goalSetting == .ACTIVE ? 1 : 0)
                    .offset(y: -60)
                    Spacer()
                    Image(.character)
                        .offset(y: -40)
                }
            }
            .padding()
            .background(
                ZStack {
                    Color.subPurple
                    
                    Circle()
                        .fill(Color.primary20)
                        .frame(width: 153, height: 153)
                        .offset(x: -160, y: 70 + (animate ? -8 : 8))
                        .animation(
                            .easeInOut(duration: 3)
                            .repeatForever(autoreverses: true),
                            value: animate
                        )

                    
                    Circle()
                        .fill(Color.primary20)
                        .frame(width: 22, height: 22)
                        .offset(x: 0 + (animate ? -2 : 2), y: 25 + (animate ? -4 : 4))
                        .animation(
                            .easeInOut(duration: 4.5)
                            .delay(0.6)
                            .repeatForever(autoreverses: true),
                            value: animate
                        )
                    
                    Circle()
                        .fill(Color.primary20)
                        .frame(width: 29, height: 29)
                        .offset(x: 110 + (animate ? -4 : 4), y: -70 + (animate ? -4 : 4))
                        .animation(
                            .easeInOut(duration: 4.5)
                            .delay(0.3)
                            .repeatForever(autoreverses: true),
                            value: animate
                        )
                    
                    Circle()
                        .fill(Color.primary20)
                        .frame(width: 19, height: 19)
                        .offset(x: 165 + (animate ? -3 : 3), y: 10 + (animate ? 3 : -3))
                        .animation(
                            .easeInOut(duration: 6)
                            .delay(0.7)
                            .repeatForever(autoreverses: true),
                            value: animate
                        )
                    
                    Circle()
                        .fill(Color.primary50)
                        .frame(width: 99, height: 99)
                        .offset(x: 210, y: -50 + (animate ? 8 : -8))
                        .scaleEffect(animate ? 1.05 : 0.95)
                        .animation(
                            .easeInOut(duration: 4)
                            .repeatForever(autoreverses: true),
                            value: animate
                        )

                }.onAppear {
                    animate = true
                }
            )
            
            ZStack{
                VStack(spacing: 0){
                    WaveBackground()
                        .fill(.primary1)
                    Rectangle()
                        .fill(.primary1)
                }
                .frame(height: 420)
                
                VStack(alignment: .trailing) {
                    HStack{
                        MainProgressView(
                            type: "성장",
                            goal: viewModel.growthRatio,
                            progress: viewModel.growthAchieved
                        )
                        Spacer()
                        MainProgressView(
                            type: "휴식",
                            goal: viewModel.restRatio,
                            progress: viewModel.restAchieved
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 5)
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("바라는 모습대로 만든 균형에 맞춰\n일상을 채워보세요.\n그 시도만으로도")
                            .textStyle(.medium18)
                            .foregroundStyle(.subPurple)
                            .multilineTextAlignment(.trailing)
                        
                        HStack(spacing: 0) {
                            Text("확실한 성취")
                                .textStyle(.bold18)
                                .foregroundStyle(.primary1)
                                .background(.subPurple)
                            Text(" 입니다.")
                                .textStyle(.medium18)
                                .foregroundStyle(.subPurple)
                        }
                    }
                    .opacity(viewModel.goalSetting == .ACTIVE ? 1 : 0)
                }
                .padding(20)
                .padding(.top, 67)
                
                if viewModel.goalSetting != .ACTIVE {
                    VStack(spacing: 0) {
                        WaveBackground()
                            .fill(.black60)
                            .background(.ultraThinMaterial)
                            .clipShape(WaveBackground())
                        
                        Rectangle()
                            .fill(.black60)
                            .background(.ultraThinMaterial)
                    }
                    .frame(height: 420)
                    
                    HeaderButtonGroup(goalSetting: viewModel.goalSetting)
                        .padding(20)
                    
                    Spacer()
                }
            }
            .offset(y: -180)
        }
    }

}

struct WaveBackground: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: rect.height * 0.35))
            path.addCurve(
                to: CGPoint(x: rect.width, y: rect.height * 0.4),
                control1: CGPoint(x: rect.width * 0.4, y: rect.height * 0.1),
                control2: CGPoint(x: rect.width * 0.7, y: rect.height * 0.55)
            )
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
        }
    }
}
