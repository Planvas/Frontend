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
        size: Int?,
        onlyAvailable: String?
    )
    case getActivityRecommend( // 활동 추천 목록 조회
        tab: TodoCategory,
        date: String?
    )
    case getActivityCategories(tab: TodoCategory)   // 카테고리 목록 조회
    case getActivityDetail(activityId: Int) // 활동 상세 조회 GET /api/activities/{id}
    case postActivity(activityId: Int, GetActivityRequestDTO: GetActivityRequestDTO) // 활동 적용(내 일정 반영)
    case postAddToMyActivities(activityId: Int, body: AddMyActivityRequestDTO) // 활동을 내 일정에 추가 POST /api/activities/{id}/my-activities
    case getCartList(tab: TodoCategory) // 장바구니 조회
    case postCart(body: PostCartItemDTO) // 장바구니 담기
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
        case .getActivityCategories:
            return "\(Self.activitiesPath)/categories"
        case .postActivity(let activityId, _):
            return "\(Self.activitiesPath)/\(activityId)/apply"
        case .postAddToMyActivities(let activityId, _):
            return "\(Self.activitiesPath)/\(activityId)/my-activities"
        case .getCartList:
            return "\(Self.cartPath)/activities"
        case .postCart:
            return "\(Self.cartPath)/activities"
        case .deleteCart(let cartItemId):
            return "\(Self.cartPath)/activities/\(cartItemId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postActivity, .postAddToMyActivities, .postCart:
            return .post
        case .getActivityList, .getActivityRecommend, .getActivityDetail, .getCartList, .getActivityCategories:
            return .get
        case .deleteCart:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case let .getActivityList(tab, categoryId, q, page, size, onlyAvailable):
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
            if let onlyAvailable {
                params["onlyAvailable"] = onlyAvailable
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
        case .getActivityCategories(let tab):
            return .requestParameters(
                parameters: ["tab": tab.rawValue],
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
        case .postCart(let body):
            return .requestJSONEncodable(body)
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
                                "title": "AI 세미나",
                                "description": "2025 AI 대전환 오픈 세미나",
                                "category": "GROWTH",
                                "point": 30,
                                "type": "NORMAL",
                                "categoryId": 1,
                                "externalUrl": "https://example.com",
                                "startDate": "2026-02-15",
                                "endDate": "2026-02-28",
                                "dDay": 16,
                                "scheduleStatus": "AVAILABLE",
                                "tipMessage": null
                            },
                            {
                                "cartItemId": 2,
                                "activityId": 102,
                                "title": "SK 하이닉스",
                                "description": "SK 하이닉스 2025 하반기 청년 Hy-Five 14기 모집",
                                "category": "GROWTH",
                                "point": 10,
                                "type": "CONTEST",
                                "categoryId": null,
                                "externalUrl": "https://skhynix.com",
                                "startDate": "2026-02-10",
                                "endDate": "2026-02-14",
                                "dDay": 2,
                                "scheduleStatus": "CAUTION",
                                "tipMessage": "[카페 알바] 일정이 있어요!\\n시간을 쪼개서 계획해 보세요"
                            },
                            {
                                "cartItemId": 3,
                                "activityId": 103,
                                "title": "엑셀 특강",
                                "description": "드림 온 아카데미 마스터 스킬 - 엑셀 활용법 단기 특강",
                                "category": "REST",
                                "point": 10,
                                "type": "NORMAL",
                                "categoryId": 2,
                                "externalUrl": null,
                                "startDate": "2026-02-01",
                                "endDate": "2026-02-11",
                                "dDay": -1,
                                "scheduleStatus": "UNAVAILABLE",
                                "tipMessage": "마감된 활동입니다."
                            }
                        ]
                    }
                }
                """
            return jsonString.data(using: .utf8)!
        case .postAddToMyActivities:
            let jsonString = """
                {
                    "resultType": "SUCCESS",
                    "error": null,
                    "success": {
                        "myActivityId": 1,
                        "activityId": 101,
                        "title": "샘플 활동",
                        "category": "GROWTH",
                        "point": 20,
                        "startDate": "2026-02-13",
                        "endDate": "2026-02-14"
                    }
                }
                """
            return jsonString.data(using: .utf8)!
        case .deleteCart:
            let jsonString = """
                {
                    "resultType": "SUCCESS",
                    "error": null,
                    "success": { "deleted": true }
                }
                """
            return jsonString.data(using: .utf8)!
            
        default:
            return Data()
        }
    }
}
