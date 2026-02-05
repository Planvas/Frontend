//
//  ActivityDTO.swift
//  Planvas
//
//  Created by 정서영 on 2/2/26.
//

// MARK: - 활동 탐색/추천 목록 조회 응답
struct ActivityListResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: ActivityListSuccess?
}

struct ActivityListSuccess: Decodable {
    let page: Int
    let size: Int
    let totalElements: Int
    let activities: [Activity]
}

struct Activity: Decodable {
    let activityId: Int
    let title: String
    let category: TodoCategory
    let point: Int
    let thumbnailUrl: String?
}

// MARK: - 활동 상세 조회
struct ActivityDetailResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: ActivityDetailSuccess?
}

struct ActivityDetailSuccess: Decodable {
    let activityId: Int
    let title: String
    let category: TodoCategory
    let point: Int
    let description: String
    let thumbnailUrl: String?
}

// MARK: - 활동 적용(내 일정 반영)
struct GetActivityRequestDTO: Encodable {
    let goalId: Int
    let startDate: String
    let endDate: String
    let point: Int
}

struct GetActivityResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: ActivityDetailSuccess?
}

struct GetActivitySuccess: Decodable {
    let myActivityId: Int
    let activityId: Int
    let title: String
    let category: TodoCategory
    let point: Int
    let startDate: String
    let endDate: String
}

// MARK: - 장바구니 조회
struct CartListResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: CartListSuccess?
}

struct CartListSuccess: Decodable {
    let tab: TodoCategory
    let items: [CartItem]
}

struct CartItem: Decodable {
    let cartItemId: Int
    let activityId: Int
    let title: String
    let category: TodoCategory
    let point: Int
    let thumbnailUrl: String?
}

// MARK: - 장바구니 담기
struct GetCartItemDTO: Encodable {
    let activityId: Int
}

struct GetCartItemResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: GetCartItemSuccess?
}

struct GetCartItemSuccess: Decodable {
    let cartItemId: Int
    let activityId: Int
    let message: String
}

// MARK: - 장바구니 삭제
struct DeleteCartItemResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: DeleteCartItemSuccess?
}

struct DeleteCartItemSuccess: Decodable {
    let deleted: Bool
}
