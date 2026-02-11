//
//  SchedulesNetworkService.swift
//  Planvas
//
//  고정 일정(fixed-schedules) / 내 활동(my-activities) API 전용 네트워크 서비스.
//  Repository만 사용. TokenPlugin으로 Authorization 헤더 자동 부착.
//

import Foundation
import Moya

enum SchedulesAPIError: Error {
    case invalidResponse
    case serverFail(reason: String)
}

final class SchedulesNetworkService: @unchecked Sendable {
    private let provider = APIManager.shared.createProvider(for: SchedulesAPI.self)

    // MARK: - 고정 일정 (fixed-schedules)

    func postAddSchedule(_ dto: CreateScheduleRequestDTO) async throws -> CreateScheduleSuccess {
        let response: CreateScheduleResponse = try await request(.postAddSchedule(CreateScheduleRequestDTO: dto))
        if let error = response.error {
            throw SchedulesAPIError.serverFail(reason: error.reason)
        }
        guard let success = response.success else {
            throw SchedulesAPIError.invalidResponse
        }
        return success
    }

    func getScheduleList() async throws -> [FixedSchedule] {
        let response: ScheduleListResponse = try await request(.getScheduleList)
        if let error = response.error {
            throw SchedulesAPIError.serverFail(reason: error.reason)
        }
        return response.success?.fixedSchedules ?? []
    }

    func patchSchedule(id: Int, _ dto: EditScheduleRequestDTO) async throws {
        let response: EditResponse = try await request(.patchSchedule(id: id, EditScheduleRequestDTO: dto))
        if let error = response.error {
            throw SchedulesAPIError.serverFail(reason: error.reason)
        }
        guard response.success != nil else {
            throw SchedulesAPIError.invalidResponse
        }
    }

    func deleteSchedule(id: Int) async throws {
        let response: DeleteResponse = try await request(.deleteSchedule(id: id))
        if let error = response.error {
            throw SchedulesAPIError.serverFail(reason: error.reason)
        }
        guard response.success != nil else {
            throw SchedulesAPIError.invalidResponse
        }
    }

    // MARK: - 내 활동 (my-activities)

    func postMyActivity(_ dto: CreateMyActivityRequestDTO) async throws -> CreateMyActivitySuccess {
        let response: CreateMyActivityResponse = try await request(.postMyActivity(CreateMyActivityRequestDTO: dto))
        if let error = response.error {
            throw SchedulesAPIError.serverFail(reason: error.reason)
        }
        guard let success = response.success else {
            throw SchedulesAPIError.invalidResponse
        }
        return success
    }

    func patchMyActivity(id: Int, _ dto: EditMyActivityRequestDTO) async throws {
        let response: EditResponse = try await request(.patchMyActivity(id: id, EditMyActivityRequestDTO: dto))
        if let error = response.error {
            throw SchedulesAPIError.serverFail(reason: error.reason)
        }
        guard response.success != nil else {
            throw SchedulesAPIError.invalidResponse
        }
    }

    func deleteMyActivity(id: Int) async throws {
        let response: DeleteResponse = try await request(.deleteMyActivity(id: id))
        if let error = response.error {
            throw SchedulesAPIError.serverFail(reason: error.reason)
        }
        guard response.success != nil else {
            throw SchedulesAPIError.invalidResponse
        }
    }

    // MARK: - Private

    private func request<T: Decodable>(_ target: SchedulesAPI) async throws -> T {
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
}
