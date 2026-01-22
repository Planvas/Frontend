//
//  ErrorResponse.swift
//  Planvas
//
//  Created by 송민교 on 1/20/26.
//
struct ErrorResponse: Decodable {
    let errorCode: String
    let reason: String?
    let data: ErrorData?
}

// TODO: - API 나오면 형식에 맞춰서 수정하기
struct ErrorData: Decodable {
    
}
