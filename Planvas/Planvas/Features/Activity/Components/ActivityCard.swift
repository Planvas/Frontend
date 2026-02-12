//
//  ActivityCard.swift
//  Planvas
//
//  Created by 황민지 on 2/12/26.
//

import SwiftUI
import Kingfisher

struct ActivityCardView: View {
    let item: ActivityCard

    var body: some View {
        VStack(spacing: 12) {

            HStack(alignment: .top, spacing: 10) {

                // 이미지
                ZStack(alignment: .topTrailing) {
                    Group {
                        if let urlString = item.imageURL,
                           let url = URL(string: urlString) {
                            
                            KFImage(url)
                                .resizable()
                                .scaledToFill()
                            
                        } else {
                            Color.ccc
                        }
                    }
                    .frame(width: 175, height: 111)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    // 배지
                    Text(item.badgeText)
                        .textStyle(.semibold14)
                        .foregroundStyle(.fff)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 4)
                        .background(item.badgeColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(.ccc, lineWidth: 0.5))
                        .padding(7)
                }
                .padding(.top, 13)
                .padding(.bottom, item.tip == nil ? 13 : 0)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top, spacing: 0) {
                        Text("성장 +\(item.growth)")
                            .textStyle(.semibold14)
                            .foregroundStyle(.primary1)
                            .padding(.top, 21)

                        Spacer()

                        Text("D-\(item.dday)")
                            .textStyle(.medium14)
                            .foregroundStyle(.fff)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(.primary1)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.top, 16)
                    }

                    Text(item.title)
                        .textStyle(.semibold16)
                }
            }
            
            if let tip = item.tip {
                TipMessageView(tip: tip)
            }
            
        }
        .padding(.horizontal, 13)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.ccc, lineWidth: 0.6)
        )
        .shadow(color: .ccc, radius: 4, x:0, y: 2)
        .frame(maxWidth: .infinity)
    }
    
    private struct TipMessageView: View {
        let tip: ActivityTip
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.subPurple)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.primary1, lineWidth: 0.5)
                    )
                
                HStack(spacing: 0) {
                    Text(tip.label) // "Tip" or "주의"
                        .textStyle(.semibold12)
                        .foregroundStyle(.fff)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(.primary1)
                        )
                    
                    Text(tip.tag)   // "카페 알바"
                        .textStyle(.bold12)
                        .foregroundStyle(.primary1)
                        .lineLimit(1)
                        .padding(.leading, 8)
                    
                    Text(tip.message)
                        .textStyle(.medium12)
                        .foregroundStyle(.primary1)
                        .lineLimit(1)
                        .padding(.leading, 2)
                    
                    Spacer()
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 12)
            }
            .frame(height: 36)
            .padding(.bottom, 12)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ActivityCardView(
            item: ActivityCard(
                imageURL: nil,
                badgeText: "일정 가능",
                badgeColor: .blue1,
                growth: 10,
                dday: 9,
                title: "패스트 캠퍼스 2026 AI 대전환 오픈 세미나",
                tip: nil
            )
        )

        ActivityCardView(
            item: ActivityCard(
                imageURL: nil,
                badgeText: "일정 주의",
                badgeColor: .yellow1,
                growth: 20,
                dday: 15,
                title: "2026 빅데이터 분석 자격증 온라인 교육생 모집",
                tip: ActivityTip(
                    label: "Tip",
                    tag: "[카페 알바]",
                    message: "일정이 있어요! 시간을 쪼개서 계획해 보세요",
                    labelColor: .primary1
                )
            )
        )

        ActivityCardView(
            item: ActivityCard(
                imageURL: nil,
                badgeText: "일정 겹침",
                badgeColor: .red1,
                growth: 30,
                dday: 20,
                title: "제4회 2026 블레이버스 MVP 개발 해커톤",
                tip: ActivityTip(
                    label: "주의",
                    tag: "[일본 여행]",
                    message: "일정과 겹쳐요!",
                    labelColor: .red1
                )
            )
        )
    }
    .padding()
    .background(Color.fff)
}
