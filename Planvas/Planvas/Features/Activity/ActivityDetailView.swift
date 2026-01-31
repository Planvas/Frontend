//
//  ActivityDetailView.swift
//  Planvas
//
//  Created by 최우진 on 1/30/26.
//

import SwiftUI

struct ActivityDetailView: View {
    let item: Activity
    @Environment(\.dismiss) private var dismiss
    @State private var showAddScheduleSheet: Bool = false

    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()

    @State private var currentValue: Int = 20          // 가운데 숫자 20
    @State private var currentPercent: Int = 10        // 왼쪽 10%
    @State private var addedPercent: Int = 20          // +20%
    @State private var targetPercent: Int = 60         // 오른쪽 60% (표시용)
    
    @State private var bodyText: String? = nil //본문 테스트용 변수


    var body: some View {
        VStack(spacing: 0) {

            // 상단 헤더
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black1)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("성장 활동")
                    .textStyle(.semibold20)
                    .foregroundColor(.black1)

                Spacer()

                // 오른쪽 아이콘 자리(장바구니 쓰면 버튼으로)
                Image(systemName: "cart")
                    .foregroundColor(.black1)
                    .frame(width: 44, height: 44)
                    .opacity(0.0) // 일단 자리만 맞추기. 나중에 버튼으로 바꾸면 됨.
            }
            .padding(.horizontal, 10)
            
            Spacer().frame(height: 41)

            // 본문 스크롤
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    Text(item.title)
                        .textStyle(.semibold22)
                        .foregroundColor(.black1)
                    Text(item.title2)
                        .textStyle(.semibold22)
                        .foregroundColor(.black1)
                    
                    Spacer().frame(height: 8)

                    HStack(spacing: 9) {
                        Text("D-\(item.dday)") // "D-9" 같은 값 그대로
                            .textStyle(.medium14)
                            .foregroundColor(.fff)
                            .frame(height: 27)
                            .padding(.horizontal, 8)
                            .background(Color.primary1)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        Text("성장 +\(item.growth)")
                            .textStyle(.semibold18)
                            .foregroundColor(.primary1)
                    }
                    Spacer().frame(height: 12)

                    ZStack {
                        // 항상 깔리는 검은 배경
                        Color.black1

                        // 이미지가 있을 때만 중앙에 표시
                        if let imageName = item.imageName, !imageName.isEmpty {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()          // 비율 유지
                                .frame(maxWidth: 353, maxHeight: 353)
                        }
                    }
                    .frame(width: 353, height: 353)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    Spacer().frame(height: 25)

                    // 아래는 “본문/설명” 자리
                    Text(item.title) // 임시. 나중에 description 필드 있으면 그걸로 교체
                        .textStyle(.semibold18)
                        .foregroundColor(.black1)
                    
                    Spacer().frame(height: 9)


                    ZStack {
                        // 배경
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.fff)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.ccc, lineWidth: 1)
                            )

                        // 텍스트
                        Text(bodyText ?? "본문")
                            .textStyle(.medium16)
                            .foregroundColor(.gray44450)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    .frame(width: 353, height: 82)


                    Spacer().frame(height: 25)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.fff)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)

        // 하단 고정 버튼 영역
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 5.43) {
                Button {
                    // 장바구니 담기
                } label: {
                    Text("장바구니")
                        .textStyle(.semibold18)
                        .foregroundColor(.fff)
                        .frame(maxWidth: .infinity)
                        .frame(height: 51)
                        .background(Color.primary1)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)

                Button {
                    showAddScheduleSheet = true
                } label: {
                    Text("일정 추가하기")
                        .textStyle(.semibold18)
                        .foregroundColor(.black1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 51)
                        .background(Color.primary20) //15프로가 없던데요..?
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)

            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 10)
            .background(Color.fff)
            
        }
        //MARK: 일정 추가하기 클릭했을때 뷰
        .sheet(isPresented: $showAddScheduleSheet) {
            VStack(spacing: 0) {
                Spacer().frame(height: 17)

                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.black1)
                    .frame(width: 50, height: 3)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        // 제목
                        HStack(alignment: .top, spacing: 8) {
                            Rectangle()
                                .fill(Color.primary1)
                                .frame(width: 4, height: 28)
                                .cornerRadius(2)

                            Text("\(item.title) \(item.title2)")
                                .textStyle(.bold25)
                                .foregroundColor(.black1)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer().frame(height: 20)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color.primary20)
                                .frame(width: 323, height: 38)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(Color.primary1, lineWidth: 1)
                                )
                            
                            HStack {
                                Text("나의 목표 기간")
                                    .textStyle(.medium15)
                                    .foregroundColor(.gray444)
                                
                                Spacer()
                                
                                Text("11/15 ~ 12/3")
                                    .textStyle(.medium15)
                                    .foregroundColor(.gray444)
                            }
                            .padding(.horizontal, 29)
                        }

                        Spacer().frame(height: 36)

                        // 진행기간
                        VStack(alignment: .leading, spacing: 10) {
                            Text("진행기간")
                                .textStyle(.semibold20)

                            ZStack {
                                // 배경
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.bar)
                                    .frame(width: 353, height: 106)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.ccc, lineWidth: 0.5)
                                    )

                                // 내용
                                HStack(spacing: 0) {
                                    
                                    // 캘린더 아이콘
                                    Image(systemName: "calendar")
                                        .font(.system(size: 22))
                                        .foregroundColor(.gray444)
                                    
                                    Spacer().frame(width: 12.5)

                                    // 시작 날짜
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("2025년")
                                            .textStyle(.semibold14)
                                            .foregroundColor(.gray444)

                                        Text("11월 18일")
                                            .textStyle(.semibold20)
                                            .foregroundColor(.gray444)
                                    }
                                    
                                    Spacer().frame(width: 18)

                                    // 화살표
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.black1)

                                    Spacer().frame(width: 10)
                                    
                                    // 종료 날짜
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("2025년")
                                            .textStyle(.semibold14)
                                            .foregroundColor(.gray444)

                                        Text("12월 2일")
                                            .textStyle(.semibold20)
                                            .foregroundColor(.gray444)
                                    }

                                    Spacer()

                                    // 수정하기 버튼 (ZStack)
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 13)
                                            .fill(Color.fff)
                                            .frame(width: 69, height: 26)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 13)
                                                    .stroke(Color.ccc, lineWidth: 1)
                                            )

                                        Text("수정하기")
                                            .textStyle(.semibold14)
                                            .foregroundColor(.gray44450)
                                    }

                                }
                                .padding(.horizontal, 20)
                            }

                        }
                        
                        Spacer().frame(height: 28)

                        // 활동치 설정
                        VStack(alignment: .leading, spacing: 0) {
                            Text("활동치 설정")
                                .textStyle(.semibold20)
                                .foregroundColor(.gray444)
                            Spacer().frame(height: 6)

                            Text("목표한 균형치에 반영돼요")
                                .textStyle(.medium14)
                                .foregroundColor(.primary1)
                            
                            Spacer().frame(height: 10) //간격 10

                            // 활동치 설정 카드 (요청 디자인 버전)
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.fff)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.primary1, lineWidth: 1)
                                    )

                                VStack(alignment: .leading, spacing: 0) {

                                    // 상단 타이틀: "현재 달성률" "성장"
                                    HStack(spacing: 8) {
                                        Text("현재 달성률")
                                            .textStyle(.medium18)
                                            .foregroundColor(.black1)

                                        Text("성장")
                                            .textStyle(.medium14)
                                            .foregroundColor(.primary1)

                                        Spacer()
                                    }

                                    Spacer().frame(height: 8)
                                    
                                    // 퍼센트 바 영역
                                    ZStack(alignment: .leading) {

                                        // 맨 아래: 60% 영역(회색) + 테두리
                                        RoundedRectangle(cornerRadius: 13)
                                            .fill(Color.ccc) // 회색 바탕
                                            .frame(height: 26)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 13)
                                                    .stroke(Color.ccc, lineWidth: 0.5)
                                            )

                                        // 오른쪽 60% 텍스트
                                        HStack {
                                            Spacer()
                                            Text("60%")
                                                .textStyle(.medium14)
                                                .foregroundColor(Color.gray888)
                                                .padding(.trailing, 9) //오른쪽 여백
                                        }
                                        .frame(height: 26)

                                        // +20% (길이 148) - 왼쪽 정렬
                                        RoundedRectangle(cornerRadius: 13)
                                            .fill(Color.gradprimary2) //그라데이션색상
                                            .frame(width: 148, height: 26)
                                            .overlay(alignment: .trailing) {
                                                    Text("+20%")
                                                        .textStyle(.medium20)
                                                        .foregroundColor(.fff)
                                                        .padding(.trailing, 10) // 오른쪽 여백 (디자인 맞춰서 조절)
                                                }

                                        // 10%
                                        RoundedRectangle(cornerRadius: 13)
                                            .fill(Color.gradprimary1) //그라데이션색상
                                            .frame(width: 59, height: 26)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 13)
                                                    .stroke(Color.fff, lineWidth: 0.5)
                                            )
                                            .overlay(alignment: .trailing) {
                                                    Text("10%")
                                                        .textStyle(.medium20)
                                                        .foregroundColor(.fff)
                                                        .padding(.trailing, 10) //오른쪽 간격
                                                }
                                    }

                                    Spacer().frame(height: 14)
                                    
                                    // +/- 영역 (전체 149x45)
                                    HStack(spacing: 17) {
                                        Spacer()
                                        // - 버튼 (45x45, ccc)
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.ccc)
                                                .frame(width: 45, height: 45)

                                            // - 선 (10.66 x 0, 테두리 2.16 느낌: stroke로 구현)
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.primary1)
                                                .frame(width: 10.66, height: 2.16)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            // TODO: 감소 로직
                                        }

                                        // 가운데 숫자
                                        Text("20")
                                            .textStyle(.semibold20)
                                            .foregroundColor(.black1)
                                            

                                        // + 버튼 (45x45, primary1)
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.primary1)
                                                .frame(width: 45, height: 45)

                                            Text("+")
                                                .font(.system(size: 28, weight: .medium))
                                                .foregroundColor(.fff)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            // TODO: 증가 로직
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                }
                                .padding(.top, 17)
                                .padding(.bottom, 19)
                                .padding(.horizontal, 27)

                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 151)

                        }
                        
                        Spacer().frame(height: 6)

                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.primary20)
                                .frame(maxWidth: .infinity)
                                .frame(height: 29)

                            Text("공모전은 장기 프로젝트로 High(+30)을 추천해요!")
                                .textStyle(.medium14)
                                .foregroundColor(.gray444)
                                .multilineTextAlignment(.center)
                        }


                        Spacer().frame(height: 20)
                        
                        // 일정 추가 버튼
                        Button {
                            showAddScheduleSheet = false
                        } label: {
                            Text("일정 추가하기")
                                .textStyle(.semibold18)
                                .foregroundColor(.fff)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color.primary1)
                                .cornerRadius(16)
                        }
                    }
                    .padding(20)
                }
            }
            .background(Color.fff)
        }


    }
}

private func dateText(_ date: Date) -> String {
    let f = DateFormatter()
    f.locale = Locale(identifier: "ko_KR")
    f.dateFormat = "M/d"
    return f.string(from: date)
}

private func yearText(_ date: Date) -> String {
    let f = DateFormatter()
    f.locale = Locale(identifier: "ko_KR")
    f.dateFormat = "yyyy"
    return f.string(from: date)
}

private func monthDayText(_ date: Date) -> String {
    let f = DateFormatter()
    f.locale = Locale(identifier: "ko_KR")
    f.dateFormat = "M월 d일"
    return f.string(from: date)
}

// 미리보기 화면
#Preview {
    ActivityView()
}
