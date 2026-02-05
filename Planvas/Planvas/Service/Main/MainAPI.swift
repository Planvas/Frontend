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
}

extension MainAPI: APITargetType {
    var path: String {
        switch self {
        case .getMainData:
            return "/api/home"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getMainData:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getMainData:
            return .requestPlain
        }
    }
}
