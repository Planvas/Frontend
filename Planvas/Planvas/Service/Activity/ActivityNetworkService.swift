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
    func postAddToMyActivities(activityId: Int, goalId: Int, startDate: String, endDate: String, point: Int) async throws -> AddMyActivitySuccess {
        let body = AddMyActivityRequestDTO(goalId: goalId, startDate: startDate, endDate: endDate, point: point)
        let response: AddMyActivityResponse = try await request(.postAddToMyActivities(activityId: activityId, body: body))
        if let error = response.error {
            throw ActivityAPIError.serverFail(reason: error.reason)
        }
        guard let success = response.success else {
            throw ActivityAPIError.invalidResponse
        }
        return success
    }
    
    /// 활동을 장바구니에 담기 POST /api/cart
    func postCart(activityId: Int) async throws -> PostCartItemSuccess {
        let body = PostCartItemDTO(activityId: activityId)
        let response: PostCartItemResponse = try await requestAddCart(.postCart(body: body))
        if let error = response.error {
            throw ActivityAPIError.serverFail(reason: error.reason)
        }
        guard let success = response.success else {
            throw ActivityAPIError.invalidResponse
        }
        return success
    }

    private func request<T: Decodable>(_ target: ActivityAPI) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    if let rawString = String(data: response.data, encoding: .utf8) {
                        print("📍 [네트워크] 서버 응답 도착!: \(rawString)")
                    }
                    
                    do {
                        let decoded = try JSONDecoder().decode(T.self, from: response.data)
                        continuation.resume(returning: decoded)
                    } catch {
                        print("❌ [디코딩 에러]: \(error)")
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    print("❌ [네트워크 에러]: \(error.localizedDescription)")
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
    
    private func requestAddCart<T: Decodable>(_ target: ActivityAPI) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    if !(200...299).contains(response.statusCode) {
                        // 서버가 준 JSON에서 error -> reason만 뽑아내기
                        if let errorDTO = try? JSONDecoder().decode(ActivityListResponse.self, from: response.data),
                           let reason = errorDTO.error?.reason {
                            continuation.resume(throwing: ActivityAPIError.serverFail(reason: reason))
                        } else {
                            continuation.resume(throwing: ActivityAPIError.serverFail(reason: "알 수 없는 오류가 발생했습니다."))
                        }
                        return
                    }

                    do {
                        let decoded = try JSONDecoder().decode(T.self, from: response.data)
                        continuation.resume(returning: decoded)
                    } catch {
                        continuation.resume(throwing: ActivityAPIError.invalidResponse)
                    }

                case .failure(let error):
                    if let response = error.response,
                       let errorDTO = try? JSONDecoder().decode(ActivityListResponse.self, from: response.data),
                       let reason = errorDTO.error?.reason {
                        // 서버가 준 에러메시지를 ActivityAPIError로 변환해서 던짐
                        continuation.resume(throwing: ActivityAPIError.serverFail(reason: reason))
                    } else {
                        // 진짜 인터넷이 끊긴 경우 등은 그대로 에러를 던짐
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
