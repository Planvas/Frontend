//
//  ActivityNetworkService.swift
//  Planvas
//
//  Network layer for Activity API (activities, my-activities). api.md 기준.
//

import Foundation
import Moya

enum ActivityAPIError: Error {
    case invalidResponse
    case serverFail(reason: String)
    /// 409 - 일정 충돌로 추가 불가
    case scheduleConflict(reason: String?)
    /// 404 - 해당 활동 없음
    case activityNotFound(reason: String?)
    /// 400 - 요청 값 잘못됨
    case badRequest(reason: String?)
}

final class ActivityNetworkService: @unchecked Sendable {
    private let provider = APIManager.shared.createProvider(for: ActivityAPI.self)
    private let myPageProvider = APIManager.shared.createProvider(for: MyPageRouter.self)

    /// 현재 목표 조회 GET /api/goals/current
    func getCurrentGoalId() async throws -> Int? {
        let response: GoalDetailResponse = try await requestMyPage(.getCurrentGoal)
        if let error = response.error {
            throw ActivityAPIError.serverFail(reason: error.reason)
        }
        return response.success?.goalId
    }

    /// 활동 상세 조회 GET /api/activities/{activityId}
    func getActivityDetail(activityId: Int) async throws -> ActivityDetailSuccess {
        let response: ActivityDetailResponse = try await request(.getActivityDetail(activityId: activityId))
        if let error = response.error {
            throw ActivityAPIError.serverFail(reason: error.reason)
        }
        guard let success = response.success else {
            throw ActivityAPIError.invalidResponse
        }
        return success
    }

    /// 활동을 내 일정에 추가 POST /api/activities/{activityId}/my-activities
    /// - 409: 일정 충돌 추가 불가, 404: 해당 활동 없음, 400: 요청 값 잘못됨
    func postAddToMyActivities(activityId: Int, goalId: Int, startDate: String, endDate: String, point: Int) async throws -> AddMyActivitySuccess {
        let body = AddMyActivityRequestDTO(goalId: goalId, startDate: startDate, endDate: endDate, point: point)
        let target: ActivityAPI = .postAddToMyActivities(activityId: activityId, body: body)
        let (moyaResponse, decoded): (Moya.Response, AddMyActivityResponse) = try await requestWithResponse(target)
        switch moyaResponse.statusCode {
        case 409:
            let reason = decoded.error?.reason
            throw ActivityAPIError.scheduleConflict(reason: reason)
        case 404:
            let reason = decoded.error?.reason
            throw ActivityAPIError.activityNotFound(reason: reason)
        case 400:
            let reason = decoded.error?.reason
            throw ActivityAPIError.badRequest(reason: reason)
        default:
            if let error = decoded.error {
                throw ActivityAPIError.serverFail(reason: error.reason)
            }
            guard let success = decoded.success else {
                throw ActivityAPIError.invalidResponse
            }
            return success
        }
    }

    /// HTTP statusCode 확인이 필요할 때 사용 (응답 + 디코딩 결과 반환)
    private func requestWithResponse<T: Decodable>(_ target: ActivityAPI) async throws -> (Moya.Response, T) {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try JSONDecoder().decode(T.self, from: response.data)
                        continuation.resume(returning: (response, decoded))
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func request<T: Decodable>(_ target: ActivityAPI) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try JSONDecoder().decode(T.self, from: response.data)
                        continuation.resume(returning: decoded)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func requestMyPage<T: Decodable>(_ target: MyPageRouter) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            myPageProvider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try JSONDecoder().decode(T.self, from: response.data)
                        continuation.resume(returning: decoded)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - 활동 탐색 목록 조회
    func getActivityList(
        tab: TodoCategory,
        categoryId: Int? = nil,
        q: String? = nil,
        page: Int = 0,
        size: Int = 20
    ) async throws -> [ActivityCard] {
        let response: ActivityListResponse = try await request(.getActivityList(
            tab: tab,
            categoryId: categoryId,
            q: q,
            page: page,
            size: size
        ))
        
        if let error = response.error {
            throw ActivityAPIError.serverFail(reason: error.reason)
        }
        
        guard let success = response.success else { return [] }
        
        return success.activities.map { dto in
            let status = dto.scheduleStatus ?? .available
            return ActivityCard(
                activityId: dto.activityId,
                imageURL: dto.thumbnailUrl,
                badgeText: status.badgeText,
                badgeColor: status.badgeColor,
                growth: dto.point,
                dday: dto.dDay ?? 0,
                title: dto.title,
                tip: nil
            )
        }
    }
}
