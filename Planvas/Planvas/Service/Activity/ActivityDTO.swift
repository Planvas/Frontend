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
    let scheduleStatus: ScheduleStatusCategory?  // 일정 가능?주의?겹침?
    let dDay: Int?
    let tipMessage: String?
    let externalUrl: String?
}

// MARK: - 활동 상세 조회 (GET /api/activities/{activityId})
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
    let type:  String?
    let startDate: String
    let endDate: String
    let dDay: Int
    let scheduleStatus: ScheduleStatusCategory
    let tipMessage: String?
    let categoryId: Int?
    let externalUrl: String?
    let minPoint: Int
    let maxPoint: Int
    let defaultPoint: Int
}

// MARK: - 활동을 내 일정에 추가 (POST /api/activities/{activityId}/my-activities)
struct AddMyActivityRequestDTO: Encodable {
    let goalId: Int
    let startDate: String
    let endDate: String
    let point: Int
}

struct AddMyActivityResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: AddMyActivitySuccess?
}

struct AddMyActivitySuccess: Decodable {
    let myActivityId: Int
    let activityId: Int
    let title: String
    let category: String  // "GROWTH" | "REST"
    let point: Int
    let startDate: String
    let endDate: String
    let scheduleStatus: String?  // e.g. "CAUTION"
    let scheduleReason: String?
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
    let success: GetActivitySuccess?
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
    var items: [CartItem]
}

struct CartItem: Decodable {
    let cartItemId: Int
    let activityId: Int
    let title: String
    let description: String?
    let category: TodoCategory
    let point: Int
    let type: TypeCategory?
    let categoryId: Int?
    let externalUrl: String?
    let startDate: String?
    let endDate: String?
    let dDay: Int?
    let scheduleStatus: ScheduleStatusCategory
    let tipMessage: String?
}



// MARK: - 장바구니 담기
struct PostCartItemDTO: Encodable {
    let activityId: Int
}

struct PostCartItemResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: PostCartItemSuccess?
}

struct PostCartItemSuccess: Decodable {
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

// MARK: - 활동 카테고리 목록 조회 (GET /api/activities/categories?tab=GROWTH|REST)
struct ActivityCategoryListResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: ActivityCategoryListSuccess?
}

struct ActivityCategoryListSuccess: Decodable {
    let tab: TodoCategory
    let categories: [ActivityCategory]
}

struct ActivityCategory: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
    let count: Int
}

struct ActivityListPage {
    let items: [ActivityCard]
    let page: Int
    let size: Int
    let totalElements: Int
    
    var hasNext: Bool { (page + 1) * size < totalElements }
}
