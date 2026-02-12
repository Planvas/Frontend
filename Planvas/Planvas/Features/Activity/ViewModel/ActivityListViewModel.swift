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
    private let service = ActivityNetworkService()
    
    var activities: [ActivityCard] = []
    var isLoading: Bool = false
    var selectedCategoryId: Int? = nil // 카테고리 ID 매핑 필요

    // 현재 선택된 카테고리
    var selectedCategory: String = "전체"
    
    // 서버 DB와 맞춘 카테고리 ID 매핑
    private let categoryMapping: [String: Int] = [
        "공모전": 1, "학회/동아리": 2, "대외활동": 3, "어학/자격증": 4, "인턴십": 5, "교육/강연": 6
    ]

    // 카테고리 칩 리스트
    let categoryChips: [String] = [
        "전체", "공모전", "학회/동아리",
        "대외활동", "어학/자격증", "인턴십", "교육/강연"
    ]

    // 카테고리 선택
    func selectCategory(_ category: String, tab: String, searchText: String) async {
        selectedCategory = category
        selectedCategoryId = categoryMapping[category] // "전체"면 nil
        
        // 카테고리 변경 후 즉시 서버 호출
        await fetchActivities(tab: tab, searchText: searchText)
    }

    // 필터 함수
    func fetchActivities(tab: String, searchText: String = "") async {
        isLoading = true
        let categoryEnum: TodoCategory = (tab == "성장") ? .growth : .rest
        do {
            self.activities = try await service.getActivityList(
                tab: categoryEnum,
                categoryId: selectedCategoryId,
                q: searchText.isEmpty ? nil : searchText
            )
        } catch {
            print("로드 실패: \(error)")
        }
        isLoading = false
    }

    func filteredActivities(searchText: String, onlyAvailable: Bool) -> [ActivityCard] {
        var result = activities
        if onlyAvailable {
            result = result.filter { $0.badgeText == "일정 가능" }
        }
        return result
    }
}
