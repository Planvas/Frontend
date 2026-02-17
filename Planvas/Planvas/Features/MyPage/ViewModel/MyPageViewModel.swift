import Foundation
import Combine
import Moya
import Alamofire
import Observation
import CombineMoya

@Observable
@MainActor
class MyPageViewModel {
    var goalData: GoalSuccessResponse?
    var userData: UserSuccessResponse?
    var isCalendarConnected: Bool = false
    var goalErrorMessage: String?
    var userErrorMessage: String?
    var goalIsLoading: Bool = false
    var userIsLoading: Bool = false
    // 메시지 변수
    var successMessage: String?
    var alertErrorMessage: String?
    func handleError(_ message: String) {
        self.alertErrorMessage = message
    }
    
    private let calendarRepository: CalendarRepositoryProtocol = CalendarAPIRepository()
    private let provider = APIManager.shared.createProvider(for: MyPageRouter.self)
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - 마이페이지 데이터 초기화
    func fetchMyPageData() async{
        await checkCalendarStatus() // 캘린더 상태 확인
        fetchGoal() // 기존 목표 조회
        fetchUser() // 유저 데이터 조회
    }
    
    // MARK: - 날짜 형식 변환
    /// 뷰에서 호출하는 splitDate 함수 (튜플 반환)
    func splitDate(_ dateString: String?) -> (year: String, month: String, day: String) {
        guard let dateString = dateString else { return ("-", "-", "-") }
        
        // 1. ISO8601 시도 - > 그 외 API 날짜 형식
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // 2. 단순 날짜 (yyyy-MM-dd 형식) 시도 -> 현재 목표 조회 API 날짜형식
        let simpleFormatter = DateFormatter()
        simpleFormatter.dateFormat = "yyyy-MM-dd"
        simpleFormatter.calendar = Calendar(identifier: .gregorian)
        
        // 3. 우선순위에 따라 파싱 시도
        let date = isoFormatter.date(from: dateString) // 밀리초 포함 ISO
               ?? ISO8601DateFormatter().date(from: dateString) // 기본 ISO
               ?? simpleFormatter.date(from: dateString) // 단순 날짜 (yyyy-MM-dd)
        
        guard let date = date else {
            return ("-", "-", "-")
        }
        
        let calendar = Calendar.current
        return (
            "\(calendar.component(.year, from: date))",
            "\(calendar.component(.month, from: date))",
            "\(calendar.component(.day, from: date))"
        )
    }
    /// 뷰에서 호출하는 formatDate 함수
    func formatDate(dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = isoFormatter.date(from: dateString) ?? ISO8601DateFormatter().date(from: dateString)
        guard let date = date else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy.MM.dd"
        return displayFormatter.string(from: date)
    }
    
    // MARK: - 캘린더 연동 상태 조회
    private func checkCalendarStatus() async {
        do {
            let status = try await calendarRepository.getGoogleCalendarStatus()
            self.isCalendarConnected = status.connected
        } catch {
            self.isCalendarConnected = false
            print("캘린더 상태 조회 실패: \(error)")
        }
    }
    
    // MARK: - 현재 목표 조회
    func fetchGoal() {
        self.goalErrorMessage = nil
        self.goalIsLoading = true
        provider.requestPublisher(.getCurrentGoal)
            .map(GoalResponse.self)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveSubscription: { [weak self] _ in self?.goalIsLoading = true },
                receiveCompletion: { [weak self] _ in self?.goalIsLoading = false },
                receiveCancel: { [weak self] in self?.goalIsLoading = false}
            )
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.goalErrorMessage = error.localizedDescription
                        self?.alertErrorMessage = "목표 정보를 불러오지 못했어요"
                    }
                },
                receiveValue: { [weak self] (response: GoalResponse) in
                    if response.resultType == "SUCCESS" {
                        self?.goalData = response.success
                        self?.goalErrorMessage = nil
                    } else {
                        let errorMessage = response.error?.reason ?? "알 수 없는 오류가 발생했습니다."
                        self?.goalErrorMessage = errorMessage
                        self?.alertErrorMessage = "진행 중인 목표를 찾을 수 없어요"
                    }
                })
            .store(in: &cancellable)
    }
    
    // MARK: - 내 정보 조회
    func fetchUser() {
        self.userErrorMessage = nil
        self.userIsLoading = true
        provider.requestPublisher(.getUserInfo)
            .map(UserResponse.self)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveSubscription: { [weak self] _ in self?.userIsLoading = true },
                receiveCompletion: { [weak self] _ in self?.userIsLoading = false },
                receiveCancel: { [weak self] in self?.userIsLoading = false}
            )
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.userErrorMessage = error.localizedDescription
                        self?.alertErrorMessage = "내 정보를 불러오지 못했어요"
                    }
                },
                receiveValue: { [weak self] (response: UserResponse) in
                    if response.resultType == "SUCCESS" {
                        self?.userData = response.success?.user
                        self?.userErrorMessage = nil
                    } else {
                        let errorMessage = response.error?.reason ?? "알 수 없는 오류가 발생했습니다."
                        self?.userErrorMessage = errorMessage
                        self?.alertErrorMessage = "유저 정보가 유효하지 않아요"
                    }
                })
            .store(in: &cancellable)
    }
}
