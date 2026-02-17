//
//  InterestEditSheetView.swift
//  Planvas
//
//  Created by 황민지 on 2/12/26.
//

import SwiftUI
import Moya

struct InterestEditSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GoalSetupViewModel.self) private var goalVM

    @State private var tempSelectedIds: Set<UUID> = []
    
    @State private var isLoading: Bool = false
    @State private var isSaving: Bool = false
    
    private let provider = APIManager.shared.createProvider(for: OnboardingAPI.self)

    var body: some View {
        VStack(spacing: 0) {

            Spacer()

            HStack {
                VStack(alignment: .leading) {
                    Text("관심 분야")
                        .textStyle(.semibold20)

                    Text("최대 3개 선택 가능")
                        .textStyle(.medium14)
                        .foregroundStyle(.gray444)
                }

                Spacer()

                Button {
                    tempSelectedIds.removeAll()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                        Text("초기화")
                    }
                    .textStyle(.semibold14)
                    .foregroundStyle(.primary1)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            // 칩들
            FlowLayout(spacing: 5) {
                ForEach(goalVM.interestActivityTypes) { item in
                    InterestActivityComponent(
                        emoji: item.emoji,
                        title: item.title,
                        isSelected: tempSelectedIds.contains(item.id),
                        onTap: {
                            if tempSelectedIds.contains(item.id) {
                                tempSelectedIds.remove(item.id)
                            } else if tempSelectedIds.count < 3 {
                                tempSelectedIds.insert(item.id)
                            }
                        }
                    )
                }
            }
            .opacity(isLoading ? 0.5 : 1.0)
            .disabled(isLoading || isSaving)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)

            Spacer()

            // 로딩 표시(선택)
            if isLoading {
                ProgressView()
                    .padding(.bottom, 12)
            }

            PrimaryButton(title: isSaving ? "저장 중..." : "적용하기") {
                saveInterests()
            }
            .padding(.horizontal, 20)
            .disabled(isLoading || isSaving)
            
            Spacer()
        }
        .task {
            tempSelectedIds = goalVM.selectedInterestIds
            fetchMyInterestsAndApply()
        }
    }
    
    // MARK: - 내 관심사 조회
    private func fetchMyInterestsAndApply() {
        isLoading = true
        
        provider.request(.getMyInterests) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    // 상태 코드 검증
                    guard (200..<300).contains(response.statusCode) else {
                        print("조회 실패 status: \(response.statusCode)")
                        return
                    }
                    
                    do {
                        let decoded = try JSONDecoder().decode(MyInterestsResponseDTO.self, from: response.data)
                        let interests = decoded.success?.interests ?? []
                        
                        let mappedUUIDs = Set(
                            interests.compactMap { serverItem in
                                goalVM.interestActivityTypes.first(where: { $0.title == serverItem.name })?.id
                            }
                        )
                        
                        self.tempSelectedIds = mappedUUIDs
                        self.goalVM.selectedInterestIds = mappedUUIDs
                        
                    } catch {
                        print("디코딩 오류: \(error)")
                    }
                case .failure(let error):
                    print("네트워크 오류: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - 관심사 수정
    private func saveInterests() {
        isSaving = true

        let selectedServerIds: [Int] = tempSelectedIds.compactMap { uuid in
            guard let local = goalVM.interestActivityTypes.first(where: { $0.id == uuid }) else { return nil }
            return serverId(forLocalTitle: local.title)
        }

        let body = EditMyInterestsRequestDTO(interestIds: selectedServerIds.sorted())

        provider.request(.patchMyInterests(body: body)) { result in
            DispatchQueue.main.async {
                self.isSaving = false

                switch result {
                case .success(let response):
                    let isHTTPGood = (200..<300).contains(response.statusCode)
                    
                    do {
                        let decoded = try JSONDecoder().decode(EditMyInterestsResponseDTO.self, from: response.data)
                        
                        if isHTTPGood && decoded.resultType == "SUCCESS" {
                            self.goalVM.selectedInterestIds = self.tempSelectedIds
                            self.dismiss()
                        } else {
                            print("수정 실패 - Status: \(response.statusCode), Result: \(decoded.resultType)")
                        }
                    } catch {
                        print("디코딩 에러: \(error)")
                    }
                case .failure(let error):
                    print("네트워크 에러: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - 로컬 title -> 서버 interestId 매핑
    private func serverId(forLocalTitle title: String) -> Int? {
        switch title {
        case "개발/IT": return 1
        case "기획/마케팅": return 2
        case "예술/디자인": return 3
        case "인문/교육": return 4
        case "과학/공학": return 5
        case "경영/경제": return 6
        case "미디어/영상": return 7
        case "외국어": return 8
        default: return nil
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.replacingUnspecifiedDimensions().width
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width {
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
        height = y + maxHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var maxHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += maxHeight + spacing
                maxHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
    }
}
