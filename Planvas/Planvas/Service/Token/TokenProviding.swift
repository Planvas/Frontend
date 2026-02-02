//
//  TokenProviding.swift
//  Planvas
//
//  Created by 정서영 on 2/2/26.
//

import Foundation

protocol TokenProviding {
    var accessToken: String? { get set }
    func refreshToken(completion: @escaping (String?, Error?) -> Void)
}
