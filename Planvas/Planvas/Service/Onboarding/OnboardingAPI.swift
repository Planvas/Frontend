//
//  OnboardingAPI.swift
//  Planvas
//
//  Created by 정서영 on 2/2/26.
//

import Foundation
import Moya
import Alamofire

// MARK: - 온보딩/목표 API 연결
enum OnboardingAPI {
    case postGoalBase(CreateGoalRequestDTO: CreateGoalRequestDTO) // 목표 기간/이름 생성
    case patchGoalBase(goalId: Int, EditGoalRequestDTO: EditGoalRequestDTO) // 목표 기간/이름 수정
    case getGoalDetail(goalId: Int) // 목표 상세(기간+타겟비율) 조회
    case getCurrentGoal // 현재 목표 조회
    case patchGoalRatio(goalId: Int, EditRatioRequestDTO: EditRatioRequestDTO) // 성장/휴식 비율 설정·변경
    case getRatioList // 비율 추천 목록 조회
    case getGoalProgress(goalId: Int) // 목표 진행(현재 성장/휴식 비율) 조회
}

extension OnboardingAPI: APITargetType {
    private static let goalPath = "/api/goals"
    
    var path: String {
        switch self {
        case .postGoalBase:
            return "\(Self.goalPath)"
        case .patchGoalBase(let goalId, _):
            return "\(Self.goalPath)/\(goalId)"
        case .getGoalDetail(let goalId):
            return "\(Self.goalPath)/\(goalId)"
        case .getCurrentGoal:
            return "\(Self.goalPath)/current"
        case .patchGoalRatio(let goalId, _):
            return "\(Self.goalPath)/\(goalId)/ratio"
        case .getRatioList:
            return "\(Self.goalPath)/ratio-presets"
        case .getGoalProgress(let goalId):
            return "\(Self.goalPath)/\(goalId)/progress"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postGoalBase:
            return .post
        case .patchGoalBase, .patchGoalRatio:
            return .patch
        case .getGoalDetail, .getCurrentGoal, .getRatioList, .getGoalProgress:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .postGoalBase(let CreateGoalRequestDTO):
            return .requestJSONEncodable(CreateGoalRequestDTO)
        case .patchGoalBase(_, let EditGoalRequestDTO):
            return .requestJSONEncodable(EditGoalRequestDTO)
        case .getGoalDetail:
            return .requestPlain
        case .getCurrentGoal:
            return .requestPlain
        case .patchGoalRatio(_, let EditRatioRequestDTO):
            return .requestJSONEncodable(EditRatioRequestDTO)
        case .getRatioList:
            return .requestPlain
        case .getGoalProgress:
            return .requestPlain
        }
    }
}

