import Foundation
import Combine
import Moya

/// 어떤 Router(Target)든 다 받아주는 Provider
final class TokenProvider<Target: APITargetType> {
    private let provider: MoyaProvider<Target>
    
    init(isStub: Bool = false) {
        if isStub {
            self.provider = MoyaProvider<Target>(stubClosure: MoyaProvider.immediatelyStub)
        } else {
            self.provider = MoyaProvider<Target>(plugins: [TokenPlugin()])
        }
    }
    
    /// 네트워크 요청 실행, 결과를 Decodable 타입으로 반환
    func request<T: Decodable>(_ target: Target, completion: @escaping (Result<T, Error>) -> Void) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                guard (200..<300).contains(response.statusCode) else {
                    completion(.failure(MoyaError.statusCode(response)))
                    return
                }
                
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
    
    /// Combine을 위한 requestPublisher
    func requestPublisher<T: Decodable>(_ target: Target) -> AnyPublisher<T, Error> {
        return Future<T, Error> { promise in
            self.request(target) { (result: Result<T, Error>) in
                switch result {
                case .success(let decodedData):
                    promise(.success(decodedData))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
