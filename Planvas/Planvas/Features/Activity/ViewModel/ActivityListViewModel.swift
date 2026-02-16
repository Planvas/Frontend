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
    
    private var currentPage: Int = 0
    private let pageSize: Int = 20
    private var hasNext: Bool = true
    var isFetchingMore: Bool = false
    
    // 탭 변경 시 카테고리부터 갱신하고 목록 재조회
    func onChangeTab(_ tab: String, searchText: String) async {
        let categoryEnum: TodoCategory = (tab == "성장") ? .growth : .rest
        await fetchCategories(tab: categoryEnum)

        // 기본값 "전체"
        selectedCategoryName = categories.first(where: { $0.id == 0 })?.name ?? "전체"
        selectedCategoryId = nil

        await resetAndFetch(tab: tab, searchText: searchText)
    }

    // 카테고리 선택
    func selectCategory(_ category: ActivityCategory, tab: String, searchText: String) async {
        selectedCategoryName = category.name
        selectedCategoryId = (category.id == 0) ? nil : category.id
        await resetAndFetch(tab: tab, searchText: searchText)
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
    
    func resetAndFetch(tab: String, searchText: String = "") async {
        currentPage = 0
        hasNext = true
        activities = []
        await fetchFirstPage(tab: tab, searchText: searchText)
    }
    
    private func fetchFirstPage(tab: String, searchText: String) async {
        isLoading = true
        defer { isLoading = false }

        let categoryEnum: TodoCategory = (tab == "성장") ? .growth : .rest

        do {
            let pageData = try await service.getActivityListPage(
                tab: categoryEnum,
                categoryId: selectedCategoryId,
                q: searchText.isEmpty ? nil : searchText,
                page: 0,
                size: pageSize
            )
            activities = pageData.items
            currentPage = pageData.page
            hasNext = pageData.hasNext
        } catch {
            print("첫 페이지 로드 실패: \(error)")
        }
    }
    
    func loadMoreIfNeeded(currentItem: ActivityCard, tab: String, searchText: String) async {
        guard hasNext else { return }
        guard !isFetchingMore else { return }

        // 마지막 3개 근처에서 다음 페이지 요청
        guard let idx = activities.firstIndex(where: { $0.activityId == currentItem.activityId }) else { return }
        let thresholdIndex = max(activities.count - 3, 0)
        guard idx >= thresholdIndex else { return }

        isFetchingMore = true
        defer { isFetchingMore = false }

        let nextPage = currentPage + 1
        let categoryEnum: TodoCategory = (tab == "성장") ? .growth : .rest

        do {
            let pageData = try await service.getActivityListPage(
                tab: categoryEnum,
                categoryId: selectedCategoryId,
                q: searchText.isEmpty ? nil : searchText,
                page: nextPage,
                size: pageSize
            )
            activities.append(contentsOf: pageData.items)
            currentPage = pageData.page
            hasNext = pageData.hasNext
        } catch {
            print("추가 로드 실패: \(error)")
        }
    }
}
