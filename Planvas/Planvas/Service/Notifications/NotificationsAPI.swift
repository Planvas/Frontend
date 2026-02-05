//
//  NotificationsAPI.swift
//  Planvas
//
//  Created by 정서영 on 2/2/26.
//

import Foundation
import Moya
import Alamofire

// MARK: - 알림 API 연결
enum NotificationsAPI {
    case getNotification // 알림 설정 조회
    case patchNotification(NotificationSettingRequestDTO: NotificationSettingRequestDTO) // 알림 설정 변경
    case postNotification(APNsRequestDTO: APNsRequestDTO) // 푸시 토큰 등록(APNs)
    case deleteNotification(DeleteAPNsRequestDTO: DeleteAPNsRequestDTO) // 푸시 토큰 삭제(APNs)
}

extension NotificationsAPI: APITargetType {
    private static let notificationsPath = "/api/notifications"
    
    var path: String {
        switch self {
        case .getNotification:
            return "\(Self.notificationsPath)/settings"
        case .patchNotification:
            return "\(Self.notificationsPath)/settings"
        case .postNotification:
            return "\(Self.notificationsPath)/push-tokens"
        case .deleteNotification:
            return "\(Self.notificationsPath)/push-tokens"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postNotification:
            return .post
        case .getNotification:
            return .get
        case .patchNotification:
            return .patch
        case .deleteNotification:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .getNotification:
            return .requestPlain
        case .patchNotification(let NotificationSettingRequestDTO):
            return .requestJSONEncodable(NotificationSettingRequestDTO)
        case .postNotification(let APNsRequestDTO):
            return .requestJSONEncodable(APNsRequestDTO)
        case .deleteNotification(let DeleteAPNsRequestDTO):
            return .requestJSONEncodable(DeleteAPNsRequestDTO)
        }
    }
}
