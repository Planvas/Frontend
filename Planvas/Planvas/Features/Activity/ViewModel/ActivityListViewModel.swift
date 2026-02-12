//
//  ActivityListViewModel.swift
//  Planvas
//
//  Created by 황민지 on 2/12/26.
//

import Observation
import SwiftUI

@Observable
final class ActivityListViewModel {

    // 현재 선택된 카테고리
    var selectedCategory: String = "전체"

    // 카테고리 칩 리스트
    let categoryChips: [String] = [
        "전체", "공모전", "학회/동아리",
        "대외활동", "어학/자격증", "인턴십", "교육/강연"
    ]

    // 카테고리 선택
    func selectCategory(_ category: String) {
        selectedCategory = category
    }
    
    // TODO: API 연동 후 이거 지우기 - 활동 더미 데이터
    var activities: [ActivityCard] = [
        ActivityCard(
            imageURL: nil,
            badgeText: "일정 가능",
            badgeColor: .blue1,
            growth: 10,
            dday: 9,
            title: "패스트 캠퍼스 2026 AI 대전환 오픈 세미나"
        ),
        ActivityCard(
            imageURL: nil,
            badgeText: "일정 주의",
            badgeColor: .yellow1,
            growth: 20,
            dday: 5,
            title: "2026 빅데이터 분석 자격증 온라인 교육생 모집"
        ),
        ActivityCard(
            imageURL: nil,
            badgeText: "일정 겹침",
            badgeColor: .red1,
            growth: 30,
            dday: 20,
            title: "제 4회 2026 블레이버스 MVP 개발 해커톤"
        )
    ]

    // 필터 함수
    func filteredActivities(
        searchText: String,
        onlyAvailable: Bool
    ) -> [ActivityCard] {

        var result = activities

        // 검색 필터
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.contains(searchText)
            }
        }

        // TODO: 가능한 일정만 보기 필터
        
        return result
    }
}
