//
//  ActivityCardView.swift
//  Planvas
//
//  Created by 최우진 on 1/28/26.
//.textStyle(.bold25)
//.foregroundColor(.primary1)

import SwiftUI

// 하나의 활동(Activity)을 카드 형태로 표시하는 View 구조체 정의
struct ActivityCardView: View {
    
    // 외부에서 전달받는 Activity 데이터
    let item: Activity

    // 화면에 그려질 UI 구성
    var body: some View {
        
        // 카드 전체를 세로로 쌓기 위한 VStack
        VStack(spacing: 10) {
            
            // 상단 영역: 이미지 영역 + 텍스트 영역을 가로로 배치
            HStack(alignment: .top,spacing: 10) {
                
                // 상단 이미지 영역(이미지 or 회색 박스) + 우상단 뱃지
                ZStack(alignment: .topTrailing) {

                    // 이미지 or 회색 박스
                    Group {
                        if let imageName = item.imageName, !imageName.isEmpty {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Color.ccc
                        }
                    }
                    .frame(width: 175, height: 111)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.ccc, lineWidth: 1)
                    )
                    .clipped()

                    // 우상단 배지
                    Text(item.badgeText)
                        .textStyle(.semibold14)
                        .foregroundColor(.fff)
                        .frame(width: 83, height: 25)
                        .background(item.badgeType.color)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.top, 7)
                        .padding(.trailing, 7)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.ccc, lineWidth: 0.5)
                        )
                }


                // 오른쪽 텍스트 영역을 세로로 배치
                VStack(alignment: .leading, spacing: 0) {
                    
                    // 성장 수치와 D-Day를 가로로 배치
                    HStack(spacing: 8) {
                        
                        // 성장 포인트 표시
                        Text("성장 +\(item.growth)")
                            // 커스텀 텍스트 스타일 적용
                            .textStyle(.semibold14)
                            // 포인트 강조 색상
                            .foregroundColor(.primary1)

                        // 좌우 끝 정렬을 위한 Spacer
                        Spacer()

                        // D-Day 표시
                        Text("D-\(item.dday)")
                            // 커스텀 텍스트 스타일 적용
                            .textStyle(.semibold14)
                            // 텍스트 색상 흰색
                            .foregroundColor(.white)
                            // 좌우 여백
                            .padding(.horizontal, 8)
                            // 상하 여백
                            .padding(.vertical, 5)
                            // 배경색 적용
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.primary1)
                            )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    
                    Spacer().frame(height: 10)

                    // 활동 제목 표시
                    Text(item.title)
                        // 시스템 폰트 크기 16, semibold 굵기
                        .textStyle(.semibold16)
                        // 텍스트 색상 검정
                        .foregroundColor(.black1)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer().frame(height: 3)
                    // 활동 제목 표시
                    Text(item.title2)
                        // 시스템 폰트 크기 16, semibold 굵기
                        .textStyle(.semibold16)
                        // 텍스트 색상 검정
                        .foregroundColor(.black1)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        
                }
            }

            // 팁 정보가 존재할 경우에만 하단 안내 영역 표시
            if let tip = item.tipText, let tag = item.tipTag,let tipT=item.tipT {
                
                ZStack {
                    // 배경
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.subPurple)
                        .frame(width: 333, height: 36)

                    // 내용
                    HStack(spacing: 8) {

                        // Tip 박스
                        Text(tag)
                            .textStyle(.semibold14)
                            .foregroundColor(.fff)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .fill(.primary1)
                            )
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))

                        Text(tipT)
                            .textStyle(.bold14)
                            .foregroundColor(.primary1)
                            .lineLimit(1)

                        // 팁 설명 텍스트
                        Text(tip)
                            .textStyle(.medium14)
                            .foregroundColor(.primary1)
                            .lineLimit(1)

                        Spacer()
                    }
                    .padding(.horizontal, 12)
                }


            }
        }
        // 카드 내부 전체 패딩
        .padding(14)
        // 카드 배경색 흰색
        .background(Color.fff)
        // 카드 모서리를 둥글게 처리
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.ccc, lineWidth: 0.5)
        )
    }
}

// SwiftUI 미리보기 화면 정의
#Preview {
    // ActivityView를 프리뷰로 표시
    ActivityView()
}
