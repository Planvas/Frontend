//
//  ActivityAPI.swift
//  Planvas
//
//  Created by 정서영 on 2/2/26.
//

import Foundation
import Moya
import Alamofire

// MARK: - 활동 API 연결
enum ActivityAPI {
    case getActivityList( // 활동 탐색 목록 조회
        tab: TodoCategory,
        categoryId: Int?,
        q: String?,
        page: Int?,
        size: Int?
    )
    case getActivityRecommend( // 활동 추천 목록 조회
        tab: TodoCategory,
        date: String?
    )
    case getActivityDetail(activityId: Int) // 활동 상세 조회 GET /api/activities/{id}
    case postActivity(activityId: Int, GetActivityRequestDTO: GetActivityRequestDTO) // 활동 적용(내 일정 반영)
    case postAddToMyActivities(activityId: Int, body: AddMyActivityRequestDTO) // 활동을 내 일정에 추가 POST /api/activities/{id}/my-activities
    case getCartList(tab: TodoCategory) // 장바구니 조회
    case postCart(GetCartItemDTO: GetCartItemDTO) // 장바구니 담기
    case deleteCart(cartItemId: Int) // 장바구니 삭제
}

extension ActivityAPI: APITargetType {
    private static let activitiesPath = "/api/activities"
    private static let cartPath = "/api/cart"
    
    var path: String {
        switch self {
        case .getActivityList:
            return "\(Self.activitiesPath)"
        case .getActivityRecommend:
            return "\(Self.activitiesPath)/recommend"
        case .getActivityDetail(let activityId):
            return "\(Self.activitiesPath)/\(activityId)"
        case .postActivity(let activityId, _):
            return "\(Self.activitiesPath)/\(activityId)/apply"
        case .postAddToMyActivities(let activityId, _):
            return "\(Self.activitiesPath)/\(activityId)/my-activities"
        case .getCartList:
            return "\(Self.cartPath)"
        case .postCart:
            return "\(Self.cartPath)"
        case .deleteCart(let cartItemId):
            return "\(Self.cartPath)/\(cartItemId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postActivity, .postAddToMyActivities, .postCart:
            return .post
        case .getActivityList, .getActivityRecommend, .getActivityDetail, .getCartList:
            return .get
        case .deleteCart:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .getActivityList(let tab, let categoryId, let q, let page, let size):
            var params: [String: Any] = [
                "tab": tab.rawValue
            ]
            
            if let categoryId {
                params["categoryId"] = categoryId
            }
            if let q {
                params["q"] = q
            }
            if let page {
                params["page"] = page
            }
            if let size {
                params["size"] = size
            }
            
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.queryString
            )
        case .getActivityRecommend(let tab, let date):
            var params: [String: Any] = [
                "tab": tab.rawValue
            ]
            
            if let date {
                params["date"] = date
            }
            
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.queryString
            )
        case .getActivityDetail:
            return .requestPlain
        case .postActivity(_, let GetActivityRequestDTO):
            return .requestJSONEncodable(GetActivityRequestDTO)
        case .postAddToMyActivities(_, let body):
            return .requestJSONEncodable(body)
        case .getCartList(let tab):
            return .requestParameters(
                parameters: ["tab": tab.rawValue],
                encoding: URLEncoding.queryString
            )
        case .postCart(let GetCartItemDTO):
            return .requestJSONEncodable(GetCartItemDTO)
        case .deleteCart:
            return .requestPlain
        }
    }
    
    // API 연동 전 샘플데이터
    var sampleData: Data {
        switch self {
        case .getCartList(let tab):
            let jsonString = """
                {
                    "resultType": "SUCCESS",
                    "error": null,
                    "success": {
                        "tab": "\(tab.rawValue)",
                        "items": [
                            {
                                "cartItemId": 1,
                                "activityId": 101,
                                "category": "GROWTH",
                                "dDay": 16,
                                "point": 30,
                                "title": "AI 세미나",
                                "subTitle": "2025 AI 대전환 오픈 세미나",
                                "subMessage": null,
                                "endDate": "2026-02-28"
                            },
                            {
                                "cartItemId": 2,
                                "activityId": 102,
                                "category": "GROWTH",
                                "dDay": 9,
                                "point": 10,
                                "title": "SK 하이닉스",
                                "subTitle": "SK 하이닉스 2025 하반기 청년 Hy-Five 14기 모집",
                                "subMessage": "[카페 알바] 일정이 있어요!\\n시간을 쪼개서 계획해 보세요",
                                "endDate": "2026-02-21"
                            },
                            {
                                "cartItemId": 3,
                                "activityId": 103,
                                "category": "REST",
                                "dDay": 15,
                                "point": 10,
                                "title": "엑셀",
                                "subTitle": "드림 온 아카데미 마스터 스킬 - 엑셀 활용법 단기 특강",
                                "subMessage": "[카페 알바] 일정과 겹쳐요!",
                                "endDate": "2026-02-27"
                            }
                        ]
                    }
                }
                """
            return jsonString.data(using: .utf8)!
            
        default:
            return Data()
        }
    }
}
