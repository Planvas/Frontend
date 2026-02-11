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
    // 에러 메시지
    var toastMessage: String?
    var showToast: Bool = false
    
    private let calendarRepository: CalendarRepositoryProtocol = CalendarAPIRepository()
    private let provider = APIManager.shared.createProvider(for: MyPageRouter.self)
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - 에러 발생 시 호출 할 함수
    func handleError(_ message: String){
        self.toastMessage = message
        self.showToast = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showToast = false
        }
    }
    
    // MARK: - 마이페이지 데이터 초기화
    func fetchMyPageData() async{
        await checkCalendarStatus() // 캘린더 상태 확인
        fetchGoal() // 기존 목표 조회
        fetchUser() // 유저 데이터 조회
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
                        self?.handleError(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] (response: GoalResponse) in
                    if response.resultType == "SUCCESS" {
                        self?.goalData = response.success
                        self?.goalErrorMessage = nil
                    } else {
                        let errorMessage = response.error?.reason ?? "알 수 없는 오류가 발생했습니다."
                        self?.goalErrorMessage = errorMessage
                        self?.handleError(errorMessage)
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
                        self?.handleError(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] (response: UserResponse) in
                    if response.resultType == "SUCCESS" {
                        self?.userData = response.success?.user
                        self?.userErrorMessage = nil
                    } else {
                        let errorMessage = response.error?.reason ?? "알 수 없는 오류가 발생했습니다."
                        self?.userErrorMessage = errorMessage
                        self?.handleError(errorMessage)
                    }
                })
            .store(in: &cancellable)
    }
}
