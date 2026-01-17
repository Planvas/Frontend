//
//  TokenProvider.swift
//  palnBas_mango
//
//  Created by 송민교 on 1/16/26.
//
import Foundation
import Moya

// 어떤 Router(Target)든 다 받아줌
final class TokenProvider<Target: APITargetType> {
    private let provider = MoyaProvider<Target>(plugins: [AuthPlugin()])
    
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
