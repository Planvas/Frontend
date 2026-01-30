//
//  ActivityExploreViewModel.swift
//  Planvas
//
//  Created by 최우진 on 1/28/26.
//.textStyle(.bold25)
//.foregroundColor(.primary1)

import Foundation
import Combine

final class ActivityExploreViewModel: ObservableObject {

    @Published var searchText: String = ""
    @Published var onlyAvailable: Bool = false

    @Published private(set) var activities: [Activity] = []

    private let repository: ActivityRepositoryProtocol

    init(repository: ActivityRepositoryProtocol = ActivityRepository()) {
        self.repository = repository
        load()
    }

    func load() {
        activities = repository.fetchActivities()
    }

    var filteredActivities: [Activity] {
        var result = activities

        // 검색어 필터
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !keyword.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(keyword)
            }
        }

        // 토글 필터: 일정 가능만
        if onlyAvailable {
            result = result.filter { $0.badgeType == .available }
        }

        return result
    }

    var isEmptyResult: Bool {
        filteredActivities.isEmpty
    }
}
