//
//  EventDetailView.swift
//  Planvas
//
//  Created on 1/22/26.
//

import SwiftUI

struct EventDetailView: View {
    let event: Event
    let startDate: Date
    let endDate: Date
    let daysUntil: Int? // D-6 같은 카운트다운
    let targetPeriod: String? // 11/15 ~ 12/3 같은 목표 기간
    
    @StateObject private var viewModel = EventDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showEditEventView = false
    
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    var onSave: (() -> Void)?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 상단 헤더
                headerView
                    .padding(.top, 45)
                
                // 목표 기간 (활동 모드일 때만 표시)
                if viewModel.showActivitySettings, let targetPeriod = targetPeriod {
                    targetPeriodView(targetPeriod: targetPeriod)
                }
                
                // 날짜 정보 카드
                EventDateInfoCard(
                    startDate: startDate,
                    endDate: endDate,
                    isAllDay: event.isAllDay
                )
                
                // 활동치 설정 (활동 모드일 때만 표시)
                if viewModel.showActivitySettings {
                    activitySettingsView
                } else {
                    // 정보 섹션 (일반 모드일 때만 표시)
                    infoSection
                }
                
                saveButton
                    .padding(.vertical, 10)
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(.white)
        .background(editEventSheet)
        .onAppear {
            viewModel.configure(
                event: event,
                startDate: startDate,
                endDate: endDate,
                daysUntil: daysUntil,
                targetPeriod: targetPeriod
            )
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack(alignment: .center, spacing: 8) {
            // 보라색 세로 바
            Rectangle()
                .fill(event.color.uiColor)
                .frame(width: 4, height: 28)
                .cornerRadius(2)
            
            Text(event.title)
                .textStyle(.semibold30)
                .foregroundColor(.black1)
            
            Spacer()
        }
    }
    
    // MARK: - Target Period View
    private func targetPeriodView(targetPeriod: String) -> some View {
        HStack {
            Text("나의 목표 기간")
                .textStyle(.medium15)
                .foregroundColor(.black1)
            
            Spacer()
            
            Text(targetPeriod)
                .textStyle(.medium15)
                .foregroundColor(.black1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.primary20)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.primary1, lineWidth: 1)
        )
    }
    
    // MARK: - Info Section (일반 모드)
    private var infoSection: some View {
        VStack(spacing: 12) {
            Text("목표 균형에 영향을 주지 않는 일정이에요")
                .textStyle(.medium18)
                .foregroundColor(.primary1)
            
            Text("성장/휴식 활동으로\n변경할까요?")
                .textStyle(.medium20)
                .foregroundColor(.black1)
                .multilineTextAlignment(.center)
            
            Button {
                showEditEventView = true
            } label: {
                Text("활동으로 변경하기")
                    .textStyle(.semibold20)
                    .foregroundColor(.black1)
                    .frame(width: 255)
                    .padding(.vertical, 15)
                    .background(.subPurple)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.primary1, lineWidth: 0.5)
        )
    }
    
    // MARK: - Activity Settings View
    private var activitySettingsView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("활동치 설정")
                .textStyle(.semibold20)
                .foregroundColor(.black1)
            
            Text("목표한 균형치에 반영돼요")
                .textStyle(.medium14)
                .foregroundColor(.primary1)
                .padding(.bottom, 5)
            
            VStack(spacing: 16) {
                // 현재 달성률과 성장/휴식 선택
                HStack {
                    Text("현재 달성률")
                        .textStyle(.medium18)
                        .foregroundColor(.black1)
                    Spacer()
                    
                }
                
                // 성장/휴식 선택 버튼
                HStack(spacing: 15) {
                    Button {
                        viewModel.selectActivityType(.growth)
                    } label: {
                        Text("성장")
                            .textStyle(.semibold20)
                            .foregroundColor(viewModel.isActivityTypeSelected(.growth) ? .primary1 : .primary20)
                            .cornerRadius(8)
                    }
                    
                    Button {
                        viewModel.selectActivityType(.rest)
                    } label: {
                        Text("휴식")
                            .textStyle(.semibold20)
                            .foregroundColor(viewModel.isActivityTypeSelected(.rest) ? .primary1 : .primary20)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                
                // 진행 바
                VStack(spacing: 8) {
                    HStack {
                        Text("\(viewModel.displayProgress)%")
                            .textStyle(.semibold14)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.primary1)
                            .cornerRadius(8)
                        
                        Spacer()
                        
                        Text("\(viewModel.targetAchievement)%")
                            .textStyle(.regular14)
                            .foregroundColor(.gray444)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // 배경 바
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.ccc60)
                                .frame(height: 8)
                            
                            // 진행 바
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.primary1)
                                .frame(
                                    width: geometry.size.width * viewModel.progressRatio,
                                    height: 8
                                )
                                .animation(.easeInOut(duration: 0.2), value: viewModel.currentActivityValue)
                        }
                    }
                    .frame(height: 8)
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.selectedActivityType)
                
                // 숫자 조절 버튼
                HStack(spacing: 12) {
                    Button {
                        viewModel.decrementActivityValue()
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary1)
                            .frame(width: 45, height: 45)
                            .background(.minus)
                            .cornerRadius(8)
                    }
                    
                    Text("\(viewModel.currentActivityValue)")
                        .textStyle(.semibold20)
                        .foregroundColor(.black1)
                        .frame(minWidth: 50)
                    
                    Button {
                        viewModel.incrementActivityValue()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 45, height: 45)
                            .background(.primary1)
                            .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(16)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.primary1, lineWidth: 0.5)
            )
            
            // TODO: 나중에 수정하기
            // 추천 메시지?
            Text("공모전은 장기 프로젝트로 High (+30)을 추천해요!")
                .textStyle(.medium14)
                .foregroundColor(.gray444)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(.primary20)
                .cornerRadius(10)
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        PrimaryButton(title: "일정 수정하기") {
            showEditEventView = true
        }
    }
    
    // MARK: - Edit Event Sheet
    private var editEventSheet: some View {
        EmptyView()
            .sheet(isPresented: $showEditEventView) {
                EditEventView(
                    event: event,
                    startDate: startDate,
                    endDate: endDate,
                    targetPeriod: targetPeriod
                )
                .presentationDragIndicator(.visible)
            }
    }
}

// MARK: - Date Extension for EventDetailView
extension Date {
    /// 날짜를 "M월 d일" 형식으로 포맷팅
    func monthDayString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: self)
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    EventDetailView(
        event: Event(
            title: "엄마 생신",
            time: "하루종일",
            isAllDay: true,
            color: .purple2
        ),
        startDate: Date(),
        endDate: Date(),
        daysUntil: 6,
        targetPeriod: "11/15 ~ 12/3"
    )
}
