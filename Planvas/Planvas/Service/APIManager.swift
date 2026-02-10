//
//  APIManager.swift
//  Planvas
//
//  Created by 정서영 on 2/2/26.
//

import Foundation
import Moya
import Alamofire

class APIManager: @unchecked Sendable {
    static let shared = APIManager()
    
    private let tokenProvider: TokenProviding
    private let accessTokenRefresher: AccessTokenRefresher
    private let session: Session
    private let loggerPlugin: PluginType
    private let tokenPlugin: PluginType
    
    private init() {
        tokenProvider = TokenStore.shared
        accessTokenRefresher = AccessTokenRefresher(tokenProviding: tokenProvider)
        session = Session(interceptor: accessTokenRefresher)
        loggerPlugin = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        tokenPlugin = TokenPlugin()
    }
    
    /// 실제 API 요청용 MoyaProvider
    public func createProvider<T: TargetType>(for targetType: T.Type) -> MoyaProvider<T> {
        return MoyaProvider<T>(
            session: session,
            plugins: [
                loggerPlugin,
                tokenPlugin
            ]
        )
    }
    
    /// 테스트용 MoyaProvider
    public func testProvider<T: TargetType>(for targetType: T.Type) -> MoyaProvider<T> {
        return MoyaProvider<T>(
            stubClosure: MoyaProvider.immediatelyStub,
            plugins: [
                loggerPlugin,
                tokenPlugin
            ]
        )
    }
}
