//
//  ErrorDTO.swift
//  Planvas
//
//  Created by 정서영 on 2/2/26.
//

struct ErrorDTO: Decodable {
    let errorCode: String?
    let reason: String
    let data: String?
}
