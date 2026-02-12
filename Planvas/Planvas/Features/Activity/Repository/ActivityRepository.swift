//
//  ActivityRepository.swift
//  Planvas
//
//  Activity 관련 데이터를 관리하는 Repository.
//  ViewModel은 프로토콜에만 의존하고, 네트워크·DTO를 직접 알지 않습니다.
//

import Foundation

// MARK: - Protocol

protocol ActivityRepositoryProtocol {
    /// 활동 상세 조회 (GET /api/activities/{activityId})
    func getActivityDetail(activityId: Int) async throws -> ActivityDetail

    /// 활동을 내 일정에 추가 (POST /api/activities/{activityId}/my-activities)
    func addToMyActivities(activityId: Int, goalId: Int, startDate: String, endDate: String, point: Int) async throws -> AddMyActivitySuccess
}

// MARK: - API Implementation

final class ActivityAPIRepository: ActivityRepositoryProtocol {
    private let networkService: ActivityNetworkService

    init(networkService: ActivityNetworkService = ActivityNetworkService()) {
        self.networkService = networkService
    }

    func getActivityDetail(activityId: Int) async throws -> ActivityDetail {
        let dto = try await networkService.getActivityDetail(activityId: activityId)
        return ActivityDetail(from: dto)
    }

    func addToMyActivities(activityId: Int, goalId: Int, startDate: String, endDate: String, point: Int) async throws -> AddMyActivitySuccess {
        try await networkService.postAddToMyActivities(activityId: activityId, goalId: goalId, startDate: startDate, endDate: endDate, point: point)
    }
}
