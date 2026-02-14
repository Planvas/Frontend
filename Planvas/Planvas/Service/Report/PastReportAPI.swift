import Moya
import Alamofire
import Foundation

enum PastReportRouter {
    case getPastReport(year: Int?)
}

extension PastReportRouter: APITargetType {
    var path: String {
        return "api/reports/seasons"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .getPastReport(let year):
            if let year = year {
                return .requestParameters(parameters: ["year": year], encoding: URLEncoding.queryString)
            }
            return .requestPlain
        }
    }
    
    // TODO: - 서버 구축 시 sampleData 제거
    var sampleData: Data {
        let json = """
            {
                "resultType":"SUCCESS",
                "error":null,
                "success":{
                    "seasons":[
                        {
                            "goalId":12,
                            "title":"겨울방학 갓생",
                            "startDate":"2025-12-22",
                            "endDate":"2026-02-28",
                            "year":2025
                        },
                        {
                            "goalId":9,
                            "title":"2학기 기말 대비",
                            "startDate":"2025-11-20",
                            "endDate":"2025-12-15",
                            "year":2025
                        }
                    ]
                }
            }
            """
        
        return json.data(using: .utf8)!
    }
}
