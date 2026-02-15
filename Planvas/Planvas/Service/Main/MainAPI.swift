//
//  MainAPI.swift
//  Planvas
//
//  Created by 정서영 on 2/2/26.
//

import Foundation
import Moya
import Alamofire

// MARK: - 홈 API 연결
enum MainAPI {
    case getMainData // 홈 대시보드 조회
    case patchScheduleTodo(activityId: Int) // 오늘의 할 일 (스케줄 투두) 완료 상태 토글
}

extension MainAPI: APITargetType {
    var path: String {
        switch self {
        case .getMainData:
            return "/api/home"
        case .patchScheduleTodo(let activityId):
            return "/api/home/schedules/\(activityId)/status"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getMainData:
            return .get
        case .patchScheduleTodo:
            return .patch
        }
    }
    
    var task: Task {
        switch self {
        case .getMainData:
            return .requestPlain
        case .patchScheduleTodo:
            return .requestPlain
        }
    }
}
