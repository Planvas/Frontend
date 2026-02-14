import Foundation
import Alamofire
import Moya

enum ReportRouter {
    case getReport(goalId: Int)
}

extension ReportRouter: APITargetType {
    var path: String {
        switch self {
        case .getReport(let goalId):
            return "/api/reports/seasons/\(goalId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getReport:
            return .get
        }
    }
    
    var task: Task {
        return .requestPlain
    }
    
    // TODO: - 추후 삭제
    var sampleData: Data {
        let json = """
            {
                "resultType":"SUCCESS",
                "error":null,
                "success":{
                    "goal":{
                        "goalId":12,
                        "title":"겨울방학 갓생",
                        "startDate":"2025-12-22",
                        "endDate":"2026-02-28"
                    },
                    "ratio":{
                        "target":{
                            "growthRatio":70,
                            "restRatio":30
                        },
                        "actual":{
                            "growthRatio":60,
                            "restRatio":40
                        }
                    },
                    "summary":{
                        "type":"REST_LACK",
                        "title":"목표보다 더 열심히 달리셨네요!",
                        "description":"성장은 완벽하지만, 휴식이 조금 부족해요"
                    },
                    "cta":{
                        "primary":{
                            "type":"RECOMMEND",
                            "focus":"REST",
                            "label":"휴식 활동 보러가기"
                        },
                        "secondary":{
                            "type":"SET_NEXT_GOAL",
                            "label":"다음 목표 기간 설정하러 가기"
                        }
                    }
                }
            }
            """
        return json.data(using: .utf8)!
    }
}

