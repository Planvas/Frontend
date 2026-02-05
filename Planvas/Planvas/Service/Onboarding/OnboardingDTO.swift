//
//  OnboardingDTO.swift
//  Planvas
//
//  Created by 정서영 on 2/2/26.
//

import Foundation

// MARK: - 목표 기간/이름 생성
struct CreateGoalRequestDTO: Encodable {
    let presetId: Int
    let title: String
    let startDate: String
    let endDate: String
    let targetGrowthRatio: Int
    let targetRestRatio: Int
}
// 생성, 수정 응답 동일
struct CreateGoalResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: CreateGoalSuccess?
}

struct CreateGoalSuccess: Decodable {
    let goalId: Int
    let title: String
    let startDate: String
    let endDate: String
    let createdAt: String
}

// MARK: - 목표 기간/이름 수정
struct EditGoalRequestDTO: Encodable {
    let title: String?
    let startDate: String?
    let endDate: String?
    let targetGrowthRatio: Int?
    let targetRestRatio: Int?
}

// MARK: - 목표 상세(기간+타겟비율) 조회
// 현재 목표 조회와 응답 동일
struct GoalDetailResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: GoalDetailSuccess?
}

// TODO: - presetType 타입 확인 후 enum으로 리팩토링
struct GoalDetailSuccess: Decodable {
    let goalId: Int?
    let title: String?
    let startDate: String?
    let endDate: String?
    let growthRatio: Int?
    let restRatio: Int?
    let presetType: String?
    let presetId: Int?
}

// MARK: - 성장/휴식 비율 설정·변경
struct EditRatioRequestDTO: Encodable {
    let growthRatio: Int
    let restRatio: Int
}

struct EditRatioResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: EditRatioSuccess?
}

struct EditRatioSuccess: Decodable {
    let goalId: Int
    let growthRatio: Int
    let restRatio: Int
}

// MARK: - 비율 추천 목록 조회
struct RatioListResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: RatioListSuccess?
}

struct RatioListSuccess: Decodable {
    let presets: [RatioPreset]
}

struct RatioPreset: Decodable {
    let presetId: Int
    let title: String
    let description: String
    let growthRatio: Int
    let restRatio: Int
}

// MARK: - 목표 진행(현재 성장/휴식 비율) 조회
struct GoalProgressResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: GoalProgressSuccess?
}

struct GoalProgressSuccess: Decodable {
    let goalId: Int
    let currentGrowthRatio: Int
    let currentRestRatio: Int
}
