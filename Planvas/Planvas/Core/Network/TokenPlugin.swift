//
//  AuthPlugin.swift
//  palnBas_mango
//
//  Created by 송민교 on 1/16/26.
//
import Foundation
import Moya

struct AuthPlugin: PluginType {
    func didReceive(_ result: Result<Response, MoyaError>, target: any TargetType) {
        switch result {
        case .success(let response):
            if response.statusCode == 401 {
                print("AccessToken 만료")
                
                KeychainManager.shared.delete(key: "accessToken")
                
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}
