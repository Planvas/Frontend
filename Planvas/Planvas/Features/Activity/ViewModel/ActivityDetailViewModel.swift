//
//  ActivityDetailViewModel.swift
//  Planvas
//
//  Created by 정서영 on 2/12/26.
//

import Foundation
import Observation

@Observable
@MainActor
class ActivityDetailViewModel {
    // MARK: - 도메인 모델
    var activityId: Int?
    var goalId: Int?
    private(set) var activity: ActivityDetail?

    // MARK: - UI 상태
    var isLoading = false
    var errorMessage: String?
    var showAddActivity = false
    var addActivityViewModel: AddActivityViewModel?
    var addSuccessMessage: String?
    var addErrorMessage: String?

    private let repository: ActivityRepositoryProtocol
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    nonisolated init(repository: ActivityRepositoryProtocol = ActivityAPIRepository()) {
        self.repository = repository
    }

    // MARK: - 활동 상세 로드 + 현재 goalId 조회
    func loadDetailIfNeeded() async {
        guard let id = activityId else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let detailTask = repository.getActivityDetail(activityId: id)
            async let goalTask = repository.getCurrentGoalId()
            activity = try await detailTask
            goalId = try await goalTask
        } catch {
            errorMessage = (error as? ActivityAPIError)?.reason ?? error.localizedDescription
        }
    }

    // MARK: - 일정 추가 시트 열기
    func openAddActivitySheet() {
        guard let activity else { return }
        let vm = AddActivityViewModel()
        vm.title = activity.title
        vm.activityValue = activity.defaultPoint
        vm.recommendedPoint = activity.defaultPoint
        vm.growthLabel = activity.growthLabel
        vm.startDate = activity.startDate ?? Date()
        vm.endDate = activity.endDate ?? Date()
        vm.updateTargetPeriodFromDates()
        addActivityViewModel = vm
        showAddActivity = true
    }

    /// 시트 닫힐 때 호출
    func clearAddActivitySheet() {
        addActivityViewModel = nil
    }

    // MARK: - 내 일정에 추가 (POST /api/activities/{activityId}/my-activities)
    func submitAddToMyActivities() async {
        guard let vm = addActivityViewModel else { return }
        guard let id = activityId, let goalId else {
            showAddActivity = false
            addErrorMessage = "목표 정보가 없습니다."
            return
        }
        let startStr = dateFormatter.string(from: vm.startDate)
        let endStr = dateFormatter.string(from: vm.endDate)
        do {
            _ = try await repository.addToMyActivities(activityId: id, goalId: goalId, startDate: startStr, endDate: endStr, point: vm.activityValue)
            showAddActivity = false
            addSuccessMessage = "일정에 추가되었어요"
        } catch {
            addErrorMessage = (error as? ActivityAPIError)?.reason ?? error.localizedDescription
        }
    }
}

extension ActivityAPIError {
    var reason: String? {
        switch self {
        case .serverFail(let reason): return reason
        case .invalidResponse: return "응답 형식 오류"
        }
    }
}
