//
//  CalendarNetworkService.swift
//  Planvas
//
//  Created by 백지은 on 2/5/26.
//

//  Network Layer: CalendarAPI 호출, DTO 반환. Repository만 사용.

import Foundation
import Moya

enum CalendarAPIError: Error {
    case invalidResponse
    case serverFail(reason: String)
}

/// Calendar API 전용 네트워크 서비스 (APIClient). Repository가 의존.
/// 모든 요청은 APIManager의 TokenPlugin을 통해 Authorization(Bearer) 헤더가 자동 부착됨.
final class CalendarNetworkService: @unchecked Sendable {
    private let provider = APIManager.shared.createProvider(for: CalendarAPI.self)

    func connectGoogleCalendar(code: String) async throws {
        let dto = GoogleCalendarRequestDTO(code: code)
        let response: GoogleCalendarResponse = try await request(.postGoogleCalendar(GoogleCalendarRequestDTO: dto))
        if let error = response.error {
            throw CalendarAPIError.serverFail(reason: error.reason)
        }
        guard response.success != nil else {
            throw CalendarAPIError.invalidResponse
        }
    }

    func getGoogleCalendarStatus() async throws -> GoogleCalendarStateSuccess {
        let response: GoogleCalendarStateResponse = try await request(.getGoogleCalendar)
        if let error = response.error {
            throw CalendarAPIError.serverFail(reason: error.reason)
        }
        guard let success = response.success else {
            throw CalendarAPIError.invalidResponse
        }
        return success
    }

    func syncGoogleCalendar() async throws {
        let response: GoogleScheduleSyncResponse = try await request(.postGoogleSchedulesCalendar)
        if let error = response.error {
            throw CalendarAPIError.serverFail(reason: error.reason)
        }
        guard response.success != nil else {
            throw CalendarAPIError.invalidResponse
        }
    }

    func getGoogleCalendarEvents(timeMin: String?, timeMax: String?) async throws -> [GoogleCalendarEventDTO] {
        let response: GoogleScheduleListResponse = try await request(.getGoogleSchedulesCalendar(timeMin: timeMin, timeMax: timeMax))
        if let error = response.error {
            throw CalendarAPIError.serverFail(reason: error.reason)
        }
        return response.success?.events ?? []
    }

    func getMonthCalendar(year: Int, month: Int) async throws -> MonthlyCalendarSuccessDTO {
        let response: MonthlyCalendarResponse = try await request(.getMonthCalendar(year: year, month: month))
        if let error = response.error {
            throw CalendarAPIError.serverFail(reason: error.reason)
        }
        guard let success = response.success else {
            throw CalendarAPIError.invalidResponse
        }
        return success
    }

    func getDayCalendar(date: String) async throws -> DailyCalendarSuccessDTO {
        let response: DailyCalendarResponse = try await request(.getDateCalendar(date: date))
        if let error = response.error {
            throw CalendarAPIError.serverFail(reason: error.reason)
        }
        guard let success = response.success else {
            throw CalendarAPIError.invalidResponse
        }
        return success
    }

    // MARK: - Private

    private func request<T: Decodable>(_ target: CalendarAPI) async throws -> T {
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
