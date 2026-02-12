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
                .padding(.vertical, 13)

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
}

#Preview {
    ActivityCardView(
        item: ActivityCard(
            imageURL: nil,
            badgeText: "일정 가능",
            badgeColor: .blue1,
            growth: 20,
            dday: 5,
            title: "패스트 캠퍼스 2026 AI 대전환 오픈 세미나"
        )
    )
    .padding()
}

