//
//  MainHeaderView.swift
//  Planvas
//
//  Created by 정서영 on 1/26/26.
//

import SwiftUI

// MARK: - 메인 헤더 그룹
struct MainHeaderView: View {
    let goalSetting: GoalSetting
    let stateTitle: String
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Image(.logo)
                    .resizable()
                    .frame(width: 98, height: 23)
                    .padding(.top, 60)
                
                Text(stateTitle)
                    .lineLimit(nil)
                    .textStyle(.semibold30)
                    .foregroundStyle( .black1)
                    .padding(.top, 36)
                    .offset(y: goalSetting == .ing ? 0 : 30)
                
                HStack{
                    Group{
                        Text("D-17")
                            .textStyle(.medium14)
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
                                    .foregroundStyle(.primary50)
                            )
                    }
                    .opacity(goalSetting == .ing ? 1 : 0)
                    .offset(y: -60)
                    Spacer()
                    Image(.mainCharacter)
                        .offset(y: -40)
                }
            }
            .padding()
            .background(.subPurple)
            
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
                            goal: 60,
                            progress: 40
                        )
                        Spacer()
                        MainProgressView(
                            type: "휴식",
                            goal: 40,
                            progress: 10
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
                    .opacity(goalSetting == .ing ? 1 : 0)
                }
                .padding(20)
                .padding(.top, 67)
                
                if goalSetting != .ing {
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
                    
                    HeaderButtonGroup(goalSetting: goalSetting)
                        .padding(20)
                    
                    HStack{
                        Image(.mainCharacter2)
                            .offset(x: 10, y: 145)
                        Spacer()
                    }
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

#Preview {
    MainView()
}
