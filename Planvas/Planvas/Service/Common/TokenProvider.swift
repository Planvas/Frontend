import Foundation
import Moya

/// 어떤 Router(Target)든 다 받아주는 Provider
final class TokenProvider<Target: APITargetType> {
    private let provider = MoyaProvider<Target>(plugins: [TokenPlugin()])
    
    /// 네트워크 요청 실행, 결과를 Decodable 타입으로 반환
    func request<T: Decodable>(_ target: Target, completion: @escaping (Result<T, Error>) -> Void) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                do {
                    let decodedData = try response.map(T.self)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
