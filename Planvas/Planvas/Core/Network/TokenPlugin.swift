import Foundation
import Moya

struct TokenPlugin: PluginType {
    func prepare(
        _ request: URLRequest,
        target: TargetType
    ) -> URLRequest {
        
        var request = request
        
        if let token = TokenStore.shared.accessToken {
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
        }
        return request
    }
    
    /// 네트워크 응답을 받은 후 토큰 만료(401)여부 체크
    func didReceive(_ result: Result<Response, MoyaError>, target: any TargetType) {
        switch result {
        case .success(let response):
            if response.statusCode == 401 {
                print("AccessToken 만료")
                TokenStore.shared.clearSession()
                // TODO: - 토큰 만료 시 로그인화면으로 이동 or 토큰 갱신 로직이 필요
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}
