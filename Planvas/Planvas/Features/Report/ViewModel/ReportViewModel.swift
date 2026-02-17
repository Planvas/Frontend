import Foundation
import SwiftUI
import Moya
import Combine
import CombineMoya

class ReportViewModel:ObservableObject {
    @Published var reportData: ReportSuccessResponse?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private let provider = APIManager.shared.createProvider(for: ReportRouter.self)
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 뷰에서 사용할 가공된 데이터
    /// 테마 색상 결정
    var themeColor: Color {
        guard let focus = reportData?.cta.primary.focus else {return .primary1}
        return focus == "REST" ? .green1 : .blue1
    }
    
    /// 이미지 결정
    var statusImage: (name: String, width: CGFloat, height: CGFloat) {
        guard let type = reportData?.summary.type else {return ("success", 250, 140)}
        
        switch type {
        case "REST_LACK":
            return("nextRest", 230, 170)
        case "GROWTH_LACK":
            return("nextGrowth", 250, 200)
        default:
            return ("success", 250, 120)
        }
    }
    
    /// 하단(버튼 위) 코멘트 결정
    var comment: String {
        guard let actualRatio = reportData?.ratio.actual, let targetRatio = reportData?.ratio.target else { return "" }
        
        if actualRatio.growthRatio >= targetRatio.growthRatio && actualRatio.restRatio >= targetRatio.restRatio {
            return "이 기분 좋은 흐름을 이어 \n다음 시즌 목표도 세우러 가볼까요?"
        }
        if actualRatio.growthRatio < targetRatio.growthRatio {
            return "목표와는 달랐지만, 중요한 기록이에요. \n이 경험을 바탕으로 다음 계획을 세워볼까요?"
        }
        
        return "다음 시즌은 부담 없는 계획들로 \n새로운 밑그림을 그리러 가볼까요?"
    }
    
    // MARK: - 날짜 형식 변환
    func formatDate(dateString: String) -> String {
        // 1. 서버의 ISO8601 문자열을 Date 객체로 변환
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // 밀리초 포함
        
        // 2. 만약 위 형식이 안 맞으면 기본 ISO 형식을 한 번 더 시도
        let date = isoFormatter.date(from: dateString) ?? ISO8601DateFormatter().date(from: dateString)
        
        guard let date = date else { return dateString } // 변환 실패 시 원본 반환
        
        // 3. 뷰에서 보여줄 형식
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy.MM.dd"
        return displayFormatter.string(from: date)
    }
    
    // MARK: - 최종 리포트 가져오기
    func fetchReport(goalId: Int) {
        self.errorMessage = nil
        
        provider.requestPublisher(.getReport(goalId: goalId))
            .map(ReportResponse.self)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveSubscription: { [weak self] _ in self?.isLoading = true },
                receiveCompletion: { [weak self] _ in self?.isLoading = false },
                receiveCancel: { [weak self] in self?.isLoading = false }
            )
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("Network Error: \(error)")
                }
            }, receiveValue: { [weak self] (response: ReportResponse) in
                print("응답 데이터:\(response)")
                if response.resultType == "SUCCESS", let successData = response.success {
                    self?.reportData = successData
                } else {
                    self?.errorMessage = response.error?.reason ?? "알 수 없는 오류가 발생했습니다."
                }
            })
            .store(in: &cancellables)
    }
}
