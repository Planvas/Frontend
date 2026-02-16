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
    
    var categories: [ActivityCategory] = []
    var selectedCategoryId: Int? = nil
    var selectedCategoryName: String = "전체"
    
    // 탭 변경 시 카테고리부터 갱신하고 목록 재조회
    func onChangeTab(_ tab: String, searchText: String) async {
        let categoryEnum: TodoCategory = (tab == "성장") ? .growth : .rest
        await fetchCategories(tab: categoryEnum)

        // 기본값 "전체"
        selectedCategoryName = categories.first(where: { $0.id == 0 })?.name ?? "전체"
        selectedCategoryId = nil

        await fetchActivities(tab: tab, searchText: searchText)
    }

    // 카테고리 선택
    func selectCategory(_ category: ActivityCategory, tab: String, searchText: String) async {
        selectedCategoryName = category.name
        selectedCategoryId = (category.id == 0) ? nil : category.id
        await fetchActivities(tab: tab, searchText: searchText)
    }
    
    func fetchCategories(tab: TodoCategory) async {
        do {
            self.categories = try await service.getActivityCategories(tab: tab)
        } catch {
            print("카테고리 로드 실패: \(error)")
            self.categories = []
        }
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
