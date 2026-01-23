//
//  NameExpandableCard.swift
//  Planvas
//
//  Created by 황민지 on 1/19/26.
//

import SwiftUI

struct GoalPeriodCard: View {
    @ObservedObject var vm: GoalSetupViewModel
    @FocusState private var isFocused: Bool
    
    private var isExpanded: Bool {
        vm.expandedSection == .period
    }
    
    private var currentCornerRadius: CGFloat {
        isExpanded ? 25 : 15
    }

    private var dateDisplayText: String {
        if let start = vm.startDate, let end = vm.endDate {
            return "\(vm.formatDate(start)) - \(vm.formatDate(end))"
        }
        return "기간 추가"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // 닫힌 상태
            if !isExpanded {
                HStack {
                    Text("날짜")
                        .textStyle(.medium14)
                        .foregroundStyle(.gray888)
                        .padding(.leading, 2)

                    Spacer()

                    Text(dateDisplayText)
                        .textStyle(.medium14)
                        .foregroundStyle(.black1)
                        .padding(.trailing, 2)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    open()
                }
                .padding(18)
            }

            // 열린 상태
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    Text("날짜")
                        .textStyle(.semibold25)
                        .foregroundStyle(.black1)
                        .padding(.top, 26)
                        .padding(.bottom, 17)
                        .padding(.horizontal, 25)
                    
                    // 날짜 지정 버튼
                    HStack {
                        Spacer()
                        dateSelectButton
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    
                    // 캘린더
                    calendarContent
                        

                }
            }
        }
        .background(.white)
        .cornerRadius(currentCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: currentCornerRadius)
                .stroke(.ccc, lineWidth: 0.6)
        )
        .shadow(color: .black20, radius: 4, x:0, y: 2)
        .padding(.horizontal, 20)
        .onChange(of: isFocused) { oldValue, focused in
            if !focused && isExpanded {
                close()
            }
        }
    }
    
    // MARK: - 캘린더 메인 영역
    private var calendarContent: some View {
        VStack(alignment: .leading, spacing: 0) {

            let displayMonth = vm.calendar.date(byAdding: .month, value: vm.currentMonthIndex, to: vm.startOfCurrentMonth()) ?? Date()

            Text(vm.formatYearMonth(displayMonth))
                .textStyle(.semibold14)
                .foregroundStyle(.black1)
                .padding(.bottom, 20)
                .padding(.horizontal, 31)

            // 요일
            weekdayRow
                .padding(.horizontal, 17)
            
            Spacer().frame(height: 37.75)

            // 날짜
            TabView(selection: $vm.currentMonthIndex) {
                ForEach(0..<12, id: \.self) { index in
                    let month = vm.calendar.date(
                        byAdding: .month,
                        value: index,
                        to: vm.startOfCurrentMonth()
                    ) ?? Date()

                    monthGridView(for: month)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 270)
            .padding(.horizontal, 17)
            
            Spacer().frame(height: 41)
        }
    }


    // MARK: - 요일
    private var weekdayRow: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)

        return LazyVGrid(columns: columns, spacing: 0) {
            ForEach(vm.daysInWeek, id: \.self) { day in
                Text(day)
                    .textStyle(.regular14)
                    .foregroundStyle(.gray888)
            }
        }
    }


    // MARK: - 날짜 뷰
    private func monthGridView(for month: Date) -> some View {
        let days = vm.makeDays(for: month)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(days.indices, id: \.self) { index in
                if let date = days[index] {
                    dayCell(for: date)
                        .background(
                            GeometryReader { proxy in
                                Color.clear.preference(
                                    key: DatePreferenceKey.self,
                                    value: [date: proxy.frame(in: .named("calendarGrid"))]
                                )
                            }
                        )
                } else {
                    Color.clear.frame(height: 35)
                }
            }
        }
        .coordinateSpace(name: "calendarGrid")
        .backgroundPreferenceValue(DatePreferenceKey.self) { preferences in
            if let start = vm.startDate, let end = vm.endDate {

                let monthStart = vm.calendar.startOfDay(for: month)
                let monthEnd = vm.calendar.date(
                    byAdding: DateComponents(month: 1, day: -1),
                    to: monthStart
                )!

                let rangeStart = max(start, monthStart)
                let rangeEnd = min(end, monthEnd)

                let visibleFrames = preferences
                    .filter { date, _ in
                        date >= rangeStart && date <= rangeEnd
                    }

                let rows = Dictionary(grouping: visibleFrames) { (_, frame) in
                    // 같은 줄 판별용 key
                    Int(frame.midY / 10)
                }

                ZStack {
                    ForEach(rows.keys.sorted(), id: \.self) { key in
                        if let row = rows[key] {
                            let frames = row.map { $0.value }
                            let minX = frames.map { $0.minX }.min()!
                            let maxX = frames.map { $0.maxX }.max()!
                            let midY = frames.first!.midY

                            Capsule()
                            .fill(
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: .primary1.opacity(0.15), location: 0.0),
                                            .init(color: .primary1.opacity(0.25), location: 0.5),
                                            .init(color: .primary1.opacity(0.15), location: 1.0)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            .frame(width: maxX - minX - 6.5, height: 39)
                            .position(
                                x: (minX + maxX) / 2,
                                y: midY
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - 날짜 선택
    private func dayCell(for date: Date) -> some View {
        let isPast = vm.calendar.startOfDay(for: date) < vm.today
        let isSelected = (date == vm.startDate || date == vm.endDate)

        return Text("\(vm.calendar.component(.day, from: date))")
            .textStyle(.medium16)
            .foregroundStyle(isPast ? .gray : (isSelected ? .white : .black1))
            .strikethrough(isPast, color: .gray888)
            .frame(maxWidth: .infinity, minHeight: 35)
            .zIndex(1) // 텍스트가 동그라미랑 둥근 네모(선) 위로 오게 함
            .background(
                        Circle()
                            .fill(isSelected ? .primary1 : .clear)
                            .overlay(
                                // 선택된 날짜(시작일꽈 마지막일)에만 흰색 테두리 추가
                                isSelected ? Circle().stroke(Color.white, lineWidth: 0.6) : nil
                            )
                            .frame(width: 39, height: 39)
                    )
            .onTapGesture {
                if !isPast {
                    vm.handleDateSelection(date)
                }
            }
    }
    
    // MARK: - 날짜 지정 버튼
    private var dateSelectButton: some View {
        Button(action: {
            print("날짜 지정 클릭")
            close()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 100)
                    .fill(.ccc60)
                    .frame(width: 111, height: 40)
                
                RoundedRectangle(cornerRadius: 100)
                    .fill(.white)
                    .overlay(RoundedRectangle(cornerRadius: 100).stroke(.gray88850, lineWidth: 1))
                    .frame(width: 105, height: 34)
                
                Text("날짜 지정")
                    .textStyle(.medium14)
                    .foregroundColor(.black)
            }
        }
    }

    // MARK: - 카드 열고 닫기
    private func open() {
        // 이름이 설정되지 않았거나 공백이면 카드 열기 방지
        if vm.goalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("이름이 없어 기간을 설정할 수 없습니다.")
            return // 함수 종료 (카드가 열리지 않음)
        }
        
        // 시작일과 종료일이 '모두' 있을 때만 시작일 달로 이동
        if let start = vm.startDate, let _ = vm.endDate {
            let diff = vm.calendar.dateComponents([.month], from: vm.startOfCurrentMonth(), to: start)
            vm.currentMonthIndex = diff.month ?? 0
        } else {
            // 날짜가 하나만 선택됐거나 아예 없으면 무조건 이번 달로 초기화
            vm.currentMonthIndex = 0
            
            // 하나만 선택된 불완전한 상태라면 선택 취소
            vm.startDate = nil
            vm.endDate = nil
        }
        
        withAnimation(.easeInOut) {
            vm.expandedSection = .period
        }
        isFocused = true
    }

    private func close() {
        withAnimation(.easeInOut) {
            if vm.expandedSection == .period {
                vm.expandedSection = nil
            }
        }
        isFocused = false
    }
}

// MARK: - 캘린더 어디 보고 있는지
struct DatePreferenceKey: PreferenceKey {
    static var defaultValue: [Date: CGRect] = [:]
    
    static func reduce(value: inout [Date: CGRect], nextValue: () -> [Date: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - 프리뷰
#Preview("값 없음") {
    GoalPeriodCard_Perview()
}

#Preview("값 있음") {
    GoalPeriodCard_Perview(initialName: "플랜버스")
}

private struct GoalPeriodCard_Perview: View {
    @State private var goalName: String

    init(initialName: String = "") {
        _goalName = State(initialValue: initialName)
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)
                .ignoresSafeArea()

            GoalPeriodCard(vm: GoalSetupViewModel())
        }
    }
}
