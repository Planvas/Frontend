//
//  NameExpandableCard.swift
//  Planvas
//
//  Created by 황민지 on 1/19/26.
//

import SwiftUI

struct GoalPeriodCard: View {
    @ObservedObject var vm: GoalSetupViewModel

    @State private var isExpanded: Bool = false
    @FocusState private var isFocused: Bool
    
    
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
                        .foregroundStyle(.gray2)
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
                .stroke(.gray.opacity(1), lineWidth: 0.6)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x:0, y: 2)
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

            // 0000년 0월
            Text(vm.formatYearMonth(vm.currentMonth))
                .textStyle(.semibold14)
                .foregroundStyle(.black1)
                .padding(.bottom, 20)
                .padding(.horizontal, 31)

            // 요일
            weekdayRow
                .padding(.horizontal, 17)
            
            Spacer().frame(height: 37.75)

            // 날짜
            TabView(selection: $vm.currentMonth) {
                ForEach(0..<12, id: \.self) { index in
                    let month = vm.calendar.date(
                        byAdding: .month,
                        value: index,
                        to: vm.startOfCurrentMonth()
                    ) ?? Date()

                    monthGridView(for: month)
                        .tag(month)
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
                    .foregroundStyle(.gray2)
            }
        }
    }


    // MARK: - 날짜 뷰
    private func monthGridView(for month: Date) -> some View {
        let days = vm.makeDays(for: month)
        let columns = Array(repeating: GridItem(.flexible()), count: 7)

        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(days.indices, id: \.self) { index in
                if let date = days[index] {
                    dayCell(for: date)
                } else {
                    Color.clear
                        .frame(height: 35)
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
            .strikethrough(isPast, color: .gray)
            .frame(maxWidth: .infinity, minHeight: 35)
            .background(
                Circle()
                    .fill(isSelected ? .purple1 : .clear)
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
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 111, height: 40)
                
                RoundedRectangle(cornerRadius: 100)
                    .fill(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 100).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    .frame(width: 105, height: 34)
                
                Text("날짜 지정")
                    .textStyle(.medium14)
                    .foregroundColor(.black)
            }
        }
    }

    private func open() {
        // startDate가 있다면 그 달로 캘린더 열기
        if let start = vm.startDate {
            // startDate가 속한 달의 1일로 맞춰서 currentMonth 세팅
            let comps = vm.calendar.dateComponents([.year, .month], from: start)
            vm.currentMonth = vm.calendar.date(from: comps) ?? start
        } else {
            // startDate 없으면 오늘 달
            let comps = vm.calendar.dateComponents([.year, .month], from: Date())
            vm.currentMonth = vm.calendar.date(from: comps) ?? Date()
        }
        
        if vm.startDate == nil || vm.endDate == nil {
            vm.startDate = nil
            vm.endDate = nil
        }
        
        withAnimation(.easeInOut) {
            isExpanded = true
        }
        isFocused = true
    }

    private func close() {
        withAnimation(.easeInOut) {
            isExpanded = false
        }
        isFocused = false
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
