//
//  RatioSetupCard.swift
//  Planvas
//
//  Created by 황민지 on 1/25/26.
//

import SwiftUI

struct RatioSetupCard: View {
    @ObservedObject var vm: GoalSetupViewModel
    @Environment(\.displayScale) var displayScale
    
    var body: some View {
        
        let purplePercent = vm.ratioStep * 10
        let grayPercent = 100 - purplePercent
        
        let purpleLabel = "\(purplePercent)%"
        let grayLabel = "\(grayPercent)%"
        
        VStack (alignment: .center, spacing: 0){
            // TODO: 목표 이름, 기간 설정 화면 라우트 연결 후 수정 예정
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
                    .foregroundStyle(.primary1)
                
                Spacer()
                
                Text("\(grayLabel)")
                    .textStyle(.semibold20)
                    .foregroundStyle(.primary1)
                
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
                        .fill(.ccc20)
                        .frame(height: 25)

                    RoundedRectangle(cornerRadius: 100)
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: .gradprimary2, location: 0.0),
                                    .init(color: .primary1, location: 0.15)
                                ],
                                startPoint: UnitPoint(x: 0.02, y: 0.02),
                                endPoint: UnitPoint(x: 0.9, y: 12.0)
                            )
                        )
                        .frame(width: purpleWidth, height: 25)
                    
                    if vm.ratioStep > 0 && vm.ratioStep < 10 {
                        let lineX = snapToPixel(purpleWidth)
                        let barH: CGFloat = 25

                        VerticalDashedLine()
                            .stroke(
                                .primary1,
                                style: StrokeStyle(lineWidth: 0.2, lineCap: .round, dash: [0.5, 0.5])
                            )
                            .frame(width: 10, height: barH)
                            .position(x: lineX, y: barH / 2)
                            .zIndex(999)
                            .allowsHitTesting(false)
                    }
                    
                    // MARK: - 쉐브론/삼각형 인디케이터
                    // TODO: 디자인 바뀔 예정
                    let barH: CGFloat = 24
                    let size: CGFloat = 24
                    let lineX = snapToPixel(purpleWidth)

                    let clampedX = min(max(lineX, size / 2), totalWidth - size / 2)

                    Image(systemName: "arrowtriangle.up.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size, height: size)
                        .foregroundStyle(.primary1)
                        .position(x: clampedX, y: barH + (size / 2))
                        .allowsHitTesting(false)
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
            .padding(.bottom, 40)
            
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

    private struct VerticalDashedLine: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            return p
        }
    }
    
    private func snapToPixel(_ x: CGFloat) -> CGFloat {
        guard displayScale > 0 else { return x }
        return (x * displayScale).rounded() / displayScale
    }
}

#Preview {
    RatioSetupCard(vm: GoalSetupViewModel())
}
