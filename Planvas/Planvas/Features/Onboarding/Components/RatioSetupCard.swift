//
//  RatioSetupCard.swift
//  Planvas
//
//  Created by 황민지 on 1/25/26.
//

import SwiftUI

struct RatioSetupCard: View {
    @Environment(GoalSetupViewModel.self) private var vm
    @Environment(\.displayScale) var displayScale
    
    var body: some View {
        
        let purplePercent = vm.ratioStep * 10
        let grayPercent = 100 - purplePercent
        
        let purpleLabel = "\(purplePercent)%"
        let grayLabel = "\(grayPercent)%"
        
        VStack (alignment: .center, spacing: 0){
            Text(vm.goalName.isEmpty ? "플랜바스" : vm.goalName)
                .textStyle(.semibold25)
                .foregroundStyle(.black1)
                .padding(.top, 26)
                .padding(.bottom, 21)
            
            // MARK: - 성장, 휴식 멘트
            HStack (spacing: 7){
                Text("성장")
                    .textStyle(.medium20)
                    .foregroundStyle(.black1)
                
                Text("\(purpleLabel)")
                    .textStyle(.semibold20)
                    .foregroundStyle(.green1)
                
                Spacer()
                
                Text("\(grayLabel)")
                    .textStyle(.semibold20)
                    .foregroundStyle(.blue1)
                
                Text("휴식")
                    .textStyle(.medium20)
                    .foregroundStyle(.black1)
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 2)
            
            // MARK: - 비율 바 (고정 회색, 보라)
            GeometryReader { geo in
                let totalWidth = geo.size.width
                let purpleWidth = totalWidth * (CGFloat(vm.ratioStep) / 10.0)

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(LinearGradient(
                                stops: [
                                    .init(color: .blue20339F, location: 0.0),
                                    .init(color: .blue1, location: 0.70)
                                ],
                                startPoint: UnitPoint(x: 0.25, y: 0.5),
                                endPoint: UnitPoint(x: 0.95, y: 0.5)
                            )
                        )
                        .frame(height: 25)

                    RoundedRectangle(cornerRadius: 100)
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: .green425C47, location: 0.0),
                                    .init(color: .green33633D, location: 0.23),
                                    .init(color: .green0A671E, location: 0.4),
                                    .init(color: .green1, location: 1.0)
                                ],
                                startPoint: UnitPoint(x: 0.25, y: 0.5),
                                endPoint: UnitPoint(x: 0.95, y: 0.5)
                            )
                        )
                        .frame(width: purpleWidth, height: 25)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard totalWidth > 0 else {
                                vm.ratioStep = 0
                                return
                            }

                            let ratio = value.location.x / totalWidth
                            let clamped = max(0, min(1, ratio))
                            let next = Int((clamped * 10).rounded())
                            vm.ratioStep = max(0, min(10, next))
                        }
                )
            }
            .frame(height: 25)
            .padding(.horizontal, 11)
            .padding(.bottom, 30)
        }
        .background(.white)
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(.ccc, lineWidth: 0.6)
        )
        .shadow(color: .black20, radius: 4, x:0, y: 2)
        .padding(.horizontal, 20)
    }
}

#Preview {
    RatioSetupCard()
        .environment(GoalSetupViewModel())
}
