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
    case getActivityDetail(activityId: Int) // 활동 상세 조회
    case postActivity(activityId: Int, GetActivityRequestDTO: GetActivityRequestDTO) // 활동 적용(내 일정 반영)
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
        case .postActivity, .postCart:
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
        case .getCartList:
            return .requestPlain
        case .postCart(let GetCartItemDTO):
            return .requestJSONEncodable(GetCartItemDTO)
        case .deleteCart:
            return .requestPlain
        }
    }
}
