//
//  CartView.swift
//  Planvas
//
//  Created by 최우진 on 1/30/26.
//

//
//  CartView.swift
//  Planvas
//

import SwiftUI

struct CartView: View {

    enum CartTab {
        case growth
        case rest
    }

    @State private var selectedTab: CartTab = .growth

    // 성장 활동 더미 데이터는 여기서 가져옴
    private let repo = ActivityRepository()

    var body: some View {
        VStack(spacing: 0) {

            // 상단 타이틀
            Text("장바구니")
                .textStyle(.bold20)
                .foregroundColor(.black1)
                .padding(.top, 16)
                .padding(.bottom, 16)

            // 탭 (성장/휴식)
            HStack {
                tabButton(title: "성장 활동", tab: .growth)
                tabButton(title: "휴식 활동", tab: .rest)
            }
            .padding(.horizontal, 20)

            // 탭 아래 라인
            Rectangle()
                .fill(Color.line)
                .frame(height: 1)
                .padding(.top, 8)

            // 탭별 세로 스크롤
            Group {
                if selectedTab == .growth {
                    growthScroll
                } else {
                    restScroll
                }
            }
        }
        .background(Color.fff)
    }

    // 성장활동 스크롤
    private var growthScroll: some View {
        let items = repo.fetchActivities()

        return ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                ForEach(items) { item in
                    cartCard(item: item)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }

    // 휴식활동 스크롤 (일단 더미)
    private var restScroll: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.ccc, lineWidth: 1.2)
                    .frame(height: 150)

                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.ccc, lineWidth: 1.2)
                    .frame(height: 150)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }

    // 탭 버튼
    private func tabButton(title: String, tab: CartTab) -> some View {
        VStack(spacing: 6) {

            Text(title)
                .textStyle(.semibold18)
                .foregroundColor(selectedTab == tab ? .black1 : .gray444)

            Rectangle()
                .fill(selectedTab == tab ? Color.primary1 : Color.clear)
                .frame(height: 3)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedTab = tab
        }
    }

    // 장바구니 카드 전체 (스크린샷 스타일)
    private func cartCard(item: Activity) -> some View {
        HStack(spacing: 10) {

            // 카드 본체
            VStack(alignment: .leading, spacing: 0) {

                // 상단: 배지 + 일정 추가
                HStack {
                    badgeView(text: item.badgeText, color: item.badgeType.color)

                    Spacer()

                    Button {
                        // 일정 추가 액션 (나중에 연결)
                    } label: {
                        Text("일정 추가")
                            .textStyle(.medium14)
                            .foregroundColor(.black1)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .overlay(
                                Capsule()
                                    .stroke(Color.gray444, lineWidth: 1.2)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 14)
                .padding(.horizontal, 16)

                Spacer().frame(height: 14)

                // D-day + 성장
                HStack(spacing: 10) {
                    Text("D-\(item.dday)")
                        .textStyle(.semibold14)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.primary1)
                        .clipShape(Capsule())

                    Text("성장 +\(item.growth)")
                        .textStyle(.semibold16)
                        .foregroundColor(.primary1)

                    Spacer()
                }
                .padding(.horizontal, 16)

                Spacer().frame(height: 10)

                // 타이틀
                Text(item.title)
                    .textStyle(.semibold20)
                    .foregroundColor(.black1)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .padding(.horizontal, 16)

                // Tip 박스 (tipText 있을 때만)
                if let tipText = item.tipText, !tipText.isEmpty {
                    Spacer().frame(height: 14)

                    tipBox(
                        tag: item.tipTag ?? "Tip",
                        tipT: item.tipT ?? "",
                        text: tipText,
                        background: tipBackgroundColor(for: item.badgeType)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
                } else {
                    Spacer().frame(height: 14)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.fff)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(borderColor(for: item.badgeType), lineWidth: 2)
            )

            // 우측 삭제 바 (스크린샷처럼 일정 주의일 때만 보여주게 세팅)
            if showsDeleteBar(for: item.badgeType) {
                Button {
                    // 삭제 액션 (나중에 연결)
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.primary1)

                        Image(systemName: "trash")
                            .textStyle(.semibold22)
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 70)
            }
        }
    }

    // 배지 UI
    private func badgeView(text: String, color: Color) -> some View {
        Text(text)
            .textStyle(.semibold14)
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(color)
            .clipShape(Capsule())
    }

    // Tip 박스 UI
    private func tipBox(tag: String, tipT: String, text: String, background: Color) -> some View {
        HStack(spacing: 10) {

            Text(tag)
                .textStyle(.semibold14)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.primary1)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text("\(tipT) \(text)")
                .textStyle(.medium14)
                .foregroundColor(.black1)
                .lineLimit(nil)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // 테두리 색 (badgeType 기반)
    private func borderColor(for type: Activity.BadgeType) -> Color {
        switch type {
        case .available:
            return .blue1
        case .caution:
            return .yellow1
        case .conflict:
            return .red1
        }
    }

    // Tip 배경 색 (badgeType 기반)
    private func tipBackgroundColor(for type: Activity.BadgeType) -> Color {
        switch type {
        case .available:
            return Color.gray.opacity(0.12)
        case .caution:
            return Color.yellow.opacity(0.22)
        case .conflict:
            return Color.red.opacity(0.18)
        }
    }

    // 우측 삭제 바 표시 여부 (스크린샷 기준: 일정 주의에서만)
    private func showsDeleteBar(for type: Activity.BadgeType) -> Bool {
        type == .caution
    }
}

#Preview {
    CartView()
}
