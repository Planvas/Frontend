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
                        .background(Color.fff.opacity(0.9))
                        .clipShape(Circle())
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
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 12)

            // 본문 스크롤
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {

                    Text(item.title)
                        .textStyle(.bold25)
                        .foregroundColor(.black1)

                    HStack(spacing: 10) {
                        Text(item.dday) // "D-9" 같은 값 그대로
                            .textStyle(.semibold14)
                            .foregroundColor(.fff)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.primary1)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        Text("성장 +\(item.growth)")
                            .textStyle(.semibold14)
                            .foregroundColor(.primary1)
                    }

                    Group {
                        if let imageName = item.imageName, !imageName.isEmpty {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.ccc)
                                .frame(height: 260)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // 아래는 “본문/설명” 자리
                    Text(item.title) // 임시. 나중에 description 필드 있으면 그걸로 교체
                        .textStyle(.semibold16)
                        .foregroundColor(.black1)

                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.ccc, lineWidth: 1)
                        .frame(height: 56)
                        .overlay(
                            Text("본문")
                                .textStyle(.medium16)
                                .foregroundColor(.gray44450)
                        )

                    Spacer().frame(height: 90) // 하단 고정 버튼에 가려지지 않게 여유
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
            }
        }
        .background(Color.fff)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)

        // 하단 고정 버튼 영역
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button {
                    // 장바구니 담기
                } label: {
                    Text("장바구니")
                        .textStyle(.semibold18)
                        .foregroundColor(.fff)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
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
                        .frame(height: 54)
                        .background(Color.primary20)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)

            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 10)
            .background(Color.fff)
            
        }
        .sheet(isPresented: $showAddScheduleSheet) {
            // 🔽 여기 안에 바로 오른쪽 화면 디자인 작성
            VStack(spacing: 0) {

                // 손잡이
                Capsule()
                    .fill(Color.black.opacity(0.2))
                    .frame(width: 44, height: 5)
                    .padding(.top, 10)
                    .padding(.bottom, 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // 제목
                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(Color.primary1)
                                .frame(width: 4, height: 26)
                                .cornerRadius(2)

                            Text(item.title)
                                .textStyle(.bold25)
                                .foregroundColor(.black1)
                        }

                        // 나의 목표 기간
                        HStack {
                            Text("나의 목표 기간")
                                .textStyle(.medium16)

                            Spacer()

                            Text("11/15 ~ 12/3")
                                .textStyle(.medium16)
                        }
                        .padding()
                        .background(Color.primary1.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 22))

                        // 진행기간
                        VStack(alignment: .leading, spacing: 10) {
                            Text("진행기간")
                                .textStyle(.semibold20)

                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.ccc, lineWidth: 1)
                                .frame(height: 86)
                                .overlay(
                                    HStack {
                                        Text("2025년 11월 18일")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                        Spacer()
                                        Text("2025년 12월 2일")
                                        Spacer()
                                        Text("수정하기")
                                            .textStyle(.medium14)
                                            .padding(.horizontal, 12)
                                            .overlay(
                                                Capsule().stroke(Color.ccc, lineWidth: 1)
                                            )
                                    }
                                    .padding(.horizontal, 16)
                                )
                        }

                        // 활동치 설정
                        VStack(alignment: .leading, spacing: 12) {
                            Text("활동치 설정")
                                .textStyle(.semibold20)

                            Text("목표한 균형치에 반영돼요")
                                .textStyle(.medium14)
                                .foregroundColor(.primary1)

                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.primary1, lineWidth: 1)
                                .frame(height: 140)
                                .overlay(
                                    VStack(spacing: 16) {
                                        Text("현재 달성률 성장")
                                        Text("10%  +20%  → 60%")

                                        HStack(spacing: 20) {
                                            Button("-") {}
                                                .frame(width: 44, height: 44)
                                                .background(Color.ccc)
                                                .cornerRadius(10)

                                            Text("20")
                                                .textStyle(.bold20)

                                            Button("+") {}
                                                .frame(width: 44, height: 44)
                                                .background(Color.primary1)
                                                .cornerRadius(10)
                                        }
                                    }
                                )
                        }

                        // 안내 문구
                        Text("공모전은 장기 프로젝트로 High(+30)을 추천해요!")
                            .textStyle(.medium14)
                            .padding()
                            .background(Color.primary1.opacity(0.15))
                            .cornerRadius(12)

                        // 일정 추가 버튼
                        Button {
                            showAddScheduleSheet = false
                        } label: {
                            Text("일정 추가하기")
                                .textStyle(.semibold18)
                                .foregroundColor(.fff)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
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
