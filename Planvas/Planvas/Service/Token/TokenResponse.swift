//
//  TokenResponse.swift
//  Planvas
//
//  Created by 정서영 on 2/2/26.
//

import Foundation

struct TokenResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: UserInfo?
}
