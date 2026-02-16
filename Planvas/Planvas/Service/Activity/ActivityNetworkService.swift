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
    
    // MARK: - 활동 탐색 목록 조회
    func getActivityList(
        tab: TodoCategory,
        categoryId: Int? = nil,
        q: String? = nil,
        page: Int = 0,
        size: Int = 20,
        onlyAvailable: Bool
    ) async throws -> [ActivityCard] {
        let onlyAvailableString: String? = onlyAvailable ? "true" : "false"
        let response: ActivityListResponse = try await request(.getActivityList(
            tab: tab,
            categoryId: categoryId,
            q: q,
            page: page,
            size: size,
            onlyAvailable: onlyAvailableString
        ))
        
        if let error = response.error {
            throw ActivityAPIError.serverFail(reason: error.reason)
        }
        
        guard let success = response.success else { return [] }
        
        return success.activities.map { dto in
            let status = dto.scheduleStatus ?? .available
            
            let tip: ActivityTip? = {
                guard let tipMessage = dto.tipMessage, !tipMessage.isEmpty else { return nil }
                let parsed = parseTip(tipMessage)
                let label = (status == .caution) ? "주의" : "Tip"

                return ActivityTip(label: label, tag: parsed.tag, message: parsed.message)
            }()
            
            return ActivityCard(
                activityId: dto.activityId,
                imageURL: dto.thumbnailUrl,
                badgeText: status.statusTitle,
                badgeColor: status.themeColor,
                growth: dto.point,
                dday: dto.dDay ?? 0,
                title: dto.title,
                tip: tip
            )
        }
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
    
    // MARK: - 카테고리 조회
    func getActivityCategories(tab: TodoCategory) async throws -> [ActivityCategory] {
        let response: ActivityCategoryListResponse = try await request(.getActivityCategories(tab: tab))
        if let error = response.error {
            throw ActivityAPIError.serverFail(reason: error.reason)
        }
        return response.success?.categories ?? []
    }
    
    // MARK: - Tip 파싱 유틸
    private func parseTip(_ tipMessage: String) -> (tag: String, message: String) {
        let trimmed = tipMessage.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.hasPrefix("["),
           let end = trimmed.firstIndex(of: "]") {

            let tag = String(trimmed[trimmed.index(after: trimmed.startIndex)..<end])
            let restStart = trimmed.index(after: end)
            let message = String(trimmed[restStart...])
                .trimmingCharacters(in: .whitespacesAndNewlines)

            return (tag, message)
        }

        return ("", trimmed)
    }
    
    func getActivityListPage(
        tab: TodoCategory,
        categoryId: Int? = nil,
        q: String? = nil,
        page: Int,
        size: Int,
        onlyAvailable: Bool
    ) async throws -> ActivityListPage {
        let onlyAvailableString: String? = onlyAvailable ? "true" : "false"
        let response: ActivityListResponse = try await request(.getActivityList(
            tab: tab,
            categoryId: categoryId,
            q: q,
            page: page,
            size: size,
            onlyAvailable: onlyAvailableString
        ))

        if let error = response.error {
            throw ActivityAPIError.serverFail(reason: error.reason)
        }

        guard let success = response.success else {
            return ActivityListPage(items: [], page: page, size: size, totalElements: 0)
        }

        let cards: [ActivityCard] = success.activities.map { dto in
            let status = dto.scheduleStatus ?? .available

            let tip: ActivityTip? = {
                guard let tipMessage = dto.tipMessage, !tipMessage.isEmpty else { return nil }
                let parsed = parseTip(tipMessage)
                let label = (status == .caution) ? "주의" : "Tip"
                return ActivityTip(label: label, tag: parsed.tag, message: parsed.message)
            }()

            return ActivityCard(
                activityId: dto.activityId,
                imageURL: dto.thumbnailUrl,
                badgeText: status.statusTitle,
                badgeColor: status.themeColor,
                growth: dto.point,
                dday: dto.dDay ?? 0,
                title: dto.title,
                tip: tip
            )
        }

        return ActivityListPage(
            items: cards,
            page: success.page,
            size: success.size,
            totalElements: success.totalElements
        )
    }
}
