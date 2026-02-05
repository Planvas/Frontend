//
//  NotificationsDTO.swift
//  Planvas
//
//  Created by 정서영 on 2/2/26.
//

// MARK: - 알림 설정 조회/변경 응답
struct NotificationResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: NotificationSuccess?
}

struct NotificationSuccess: Decodable {
    let dDayReminderEnabled: Bool
    let activityCompleteReminderEnabled: Bool
}

// MARK: - 알림 설정 변경
struct NotificationSettingRequestDTO: Encodable {
    let dDayReminderEnabled: Bool
    let activityCompleteReminderEnabled: Bool
}

// MARK: - 푸시 토큰 등록(APNs)
struct APNsRequestDTO: Encodable {
    let platform: String
    let token: String
    let environment: EnvironmentCategory
}

enum EnvironmentCategory: String, Codable {
    case sandbox = "SANDBOX"
    case production = "PRODUCTION"
}

struct APNsResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: APNsSuccess?
}

struct APNsSuccess: Decodable {
    let registered: Bool
}

// MARK: - 푸시 토큰 삭제(APNs)
struct DeleteAPNsRequestDTO: Encodable {
    let platform: String
    let token: String
}

struct DeleteAPNsResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: DeleteAPNsSuccess?
}

struct DeleteAPNsSuccess: Decodable {
    let deleted: Bool
}
