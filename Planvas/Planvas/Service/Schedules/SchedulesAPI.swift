//
//  SchedulesAPI.swift
//  Planvas
//
//  Created by 정서영 on 2/2/26.
//

import Foundation
import Moya
import Alamofire

// MARK: - 일정 API 연결
enum SchedulesAPI {
    case postAddSchedule(CreateScheduleRequestDTO: CreateScheduleRequestDTO) // 고정 일정 수동 추가
    case getScheduleList // 고정 일정 목록 조회
    case patchSchedule(id: Int, EditScheduleRequestDTO: EditScheduleRequestDTO) // 고정 일정 수정
    case deleteSchedule(id: Int) // 고정 일정 삭제
    case getToDo(date: String) // 할 일 조회
    case patchToDo(todoId: Int) // 할 일 완료
    case postMyActivity(CreateMyActivityRequestDTO: CreateMyActivityRequestDTO) // 내 활동 생성
    case getMyActivityDetail(id: Int) // 내 활동 상세 조회
    case patchMyActivity(id: Int, EditMyActivityRequestDTO: EditMyActivityRequestDTO) // 내 활동 수정
    case deleteMyActivity(id: Int) // 내 활동 삭제
    case patchActivityComplete(id: Int) // 활동 완료 처리
}

extension SchedulesAPI: APITargetType {
    private static let schedulePath = "/api/fixed-schedules"
    private static let todoPath = "/api/todos"
    private static let myActivityPath = "/api/my-activities"
    
    var path: String {
        switch self {
        case .postAddSchedule:
            return "\(Self.schedulePath)"
        case .getScheduleList:
            return "\(Self.schedulePath)"
        case .patchSchedule(let id, _):
            return "\(Self.schedulePath)/\(id)"
        case .deleteSchedule(let id):
            return "\(Self.schedulePath)/\(id)"
        case .getToDo:
            return "\(Self.todoPath)"
        case .patchToDo(let todoId):
            return "\(Self.todoPath)/\(todoId)"
        case .postMyActivity:
            return "\(Self.myActivityPath)"
        case .getMyActivityDetail(let id):
            return "\(Self.myActivityPath)/\(id)"
        case .patchMyActivity(let id, _):
            return "\(Self.myActivityPath)/\(id)"
        case .deleteMyActivity(let id):
            return "\(Self.myActivityPath)/\(id)"
        case .patchActivityComplete(let id):
            return "\(Self.myActivityPath)/\(id)/complete"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postAddSchedule, .postMyActivity:
            return .post
        case .getScheduleList, .getToDo, .getMyActivityDetail:
            return .get
        case .patchSchedule, .patchToDo, .patchMyActivity, .patchActivityComplete:
            return .patch
        case .deleteSchedule, .deleteMyActivity:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .postAddSchedule(let CreateScheduleRequestDTO):
            return .requestJSONEncodable(CreateScheduleRequestDTO)
        case .getScheduleList:
            return .requestPlain
        case .patchSchedule(_, let EditScheduleRequestDTO):
            return .requestJSONEncodable(EditScheduleRequestDTO)
        case .deleteSchedule:
            return .requestPlain
        case .getToDo(let date):
            return .requestParameters(
                parameters: ["date": date],
                encoding: URLEncoding.queryString
            )
        case .patchToDo:
            return .requestPlain
        case .postMyActivity(let CreateMyActivityRequestDTO):
            return .requestJSONEncodable(CreateMyActivityRequestDTO)
        case .getMyActivityDetail:
            return .requestPlain
        case .patchMyActivity(_, let EditMyActivityRequestDTO):
            return .requestJSONEncodable(EditMyActivityRequestDTO)
        case .deleteMyActivity:
            return .requestPlain
        case .patchActivityComplete:
            return .requestPlain
        }
    }
}
