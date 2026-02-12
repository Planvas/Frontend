//
//  CalendarAPI.swift
//  Planvas
//
//  Created by 정서영 on 2/2/26.
//

import Foundation
import Moya
import Alamofire

// MARK: - 캘린더 API 연결
// 월간/일간 조회 path·파라미터 및 DTO는 API 확정 후 수정 예정.
enum CalendarAPI {
    case postGoogleCalendar(GoogleCalendarRequestDTO: GoogleCalendarRequestDTO) // 구글 캘린더 연동 요청
    case getGoogleCalendar // 구글 캘린더 연동 상태 조회
    case postGoogleSchedulesCalendar // 구글 캘린더 일정 동기화
    case getGoogleSchedulesCalendar(timeMin: String?, timeMax: String?) // 구글 캘린더 가져올 일정 목록 조회
    case getMonthCalendar(year: Int, month: Int) // 월간 캘린더 조회
    case getDateCalendar(date: String) // 일간 캘린더 조회 - (YYYY-MM-DD)형식 날짜 조회
    case postEvent(body: CreateEventRequestDTO) // 일정 추가 POST /api/calendar/event
    case patchEvent(id: Int, body: UpdateEventRequestDTO) // 일정 수정 PATCH /api/calendar/event/{id}
    case deleteEvent(id: Int) // 일정 삭제 DELETE /api/calendar/event/{id}
}

extension CalendarAPI: APITargetType {
    var path: String {
        switch self {
        case .postGoogleCalendar:
            return "/api/integrations/google-calendar/connect"
        case .getGoogleCalendar:
            return "/api/integrations/google-calendar/status"
        case .postGoogleSchedulesCalendar:
            return "/api/integrations/google-calendar/sync"
        case .getGoogleSchedulesCalendar:
            return "/api/integrations/google-calendar/events"
        case .getMonthCalendar:
            return "/api/calendar/month"
        case .getDateCalendar:
            return "/api/calendar/day"
        case .postEvent:
            return "/api/calendar/event"
        case .patchEvent(let id, _):
            return "/api/calendar/event/\(id)"
        case .deleteEvent(let id):
            return "/api/calendar/event/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postGoogleCalendar, .postGoogleSchedulesCalendar, .postEvent:
            return .post
        case .getGoogleCalendar, .getGoogleSchedulesCalendar, .getMonthCalendar, .getDateCalendar:
            return .get
        case .patchEvent:
            return .patch
        case .deleteEvent:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .postGoogleCalendar(let GoogleCalendarRequestDTO):
            return .requestJSONEncodable(GoogleCalendarRequestDTO)
        case .getGoogleCalendar:
            return .requestPlain
        case .postGoogleSchedulesCalendar:
            return .requestPlain
        case .getGoogleSchedulesCalendar(let timeMin, let timeMax):
            var params: [String: Any] = [:]

            if let timeMin {
                params["timeMin"] = timeMin
            }
            if let timeMax {
                params["timeMax"] = timeMax
            }

            if params.isEmpty {
                return .requestPlain
            } else {
                return .requestParameters(
                    parameters: params,
                    encoding: URLEncoding.queryString
                )
            }
        case .getMonthCalendar(let year, let month ):
            return .requestParameters(
                parameters: ["year": year, "month": month],
                encoding: URLEncoding.queryString
            )
        case .getDateCalendar(let date):
            return .requestParameters(
                parameters: ["date": date],
                encoding: URLEncoding.queryString
            )
        case .postEvent(let body):
            return .requestJSONEncodable(body)
        case .patchEvent(_, let body):
            return .requestJSONEncodable(body)
        case .deleteEvent:
            return .requestPlain
        }
    }
}
