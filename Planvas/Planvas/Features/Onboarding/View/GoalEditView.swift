//
//  GoalEditView.swift
//  Planvas
//
//  Created by 황민지 on 2/13/26.
//

import SwiftUI

struct GoalEditView: View {
    @Environment(NavigationRouter<MyPageRoute>.self) var router
    @Environment(GoalSetupViewModel.self) private var vm
    @Environment(MyPageViewModel.self) private var myVM
    
    @State private var isShowingStartDatePicker = false
    @State private var isShowingEndDatePicker = false
    
    @State private var tempStartDate = Date()
    @State private var tempEndDate = Date()
    @State private var editingDateType: EditingDateType? = nil

    private enum EditingDateType {
        case start, end
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // 현재 목표 수정하기
                HeaderGroup
                    .padding(.bottom, 34)
                
                // 이름 수정
                Text("목표 기간 이름")
                    .textStyle(.semibold20)
                    .padding(.bottom, 10)
                    .padding(.horizontal, 20)
                
                GoalNameEditGroup(text: $vm.goalName)
                    .padding(.bottom, 30)
                    .padding(.horizontal, 20)

                // 기간 수정
                Text("진행 기간")
                    .textStyle(.semibold20)
                    .padding(.bottom, 10)
                    .padding(.horizontal, 20)

                GoalPeriodEditGroup(start: $vm.startDate, end: $vm.endDate)
                    .padding(.bottom, 30)
                    .padding(.horizontal, 20)

                
                // 목표 비율 수정
                Text("목표 균형")
                    .textStyle(.semibold20)
                    .padding(.bottom, 10)
                    .padding(.horizontal, 20)

                GoalRatioGroup(ratio: $vm.ratioStep)
                    .padding(.bottom, 8)
                    .padding(.horizontal, 20)

                GoalRatioEditGroup(ratio: $vm.ratioStep)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)

                // 버튼
                PrimaryButton(title: "저장하기") {
                    print("성장: \(vm.growthPercent)% / 휴식: \(vm.restPercent)%")
                    
                    // TODO: 목표 수정하기 API 연동
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 75)
        }
        .navigationBarBackButtonHidden()
        .task {
            print("수정 페이지 진입 완료. 현재 설정된 이름: \(vm.goalName), Step: \(vm.ratioStep)")
        }
        .sheet(isPresented: $isShowingStartDatePicker) {
            datePickerSheet(
                title: "시작 날짜 선택",
                selection: $tempStartDate
            ) {
                vm.startDate = tempStartDate
                
                if let end = vm.endDate, end < tempStartDate {
                    vm.endDate = tempStartDate
                }
                
                isShowingStartDatePicker = false
            }
        }

        .sheet(isPresented: $isShowingEndDatePicker) {
            let minDate = vm.startDate ?? Date()
            datePickerSheet(
                title: "종료 날짜 선택",
                selection: $tempEndDate,
                range: minDate...
            ) {
                vm.endDate = tempEndDate
                isShowingEndDatePicker = false
            }
        }
    }
    
    // MARK: - 헤더
    private var HeaderGroup: some View {
        ZStack{
            HStack{
                Button(action:{
                    router.pop()
                }){
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .frame(width: 11, height: 18)
                        .foregroundStyle(.black1)
                }
                Spacer()
            }
            Text("현재 목표 수정하기")
                .textStyle(.bold20)
                .foregroundStyle(.black1)
        }
        .padding()
    }
    
    // MARK: - 목표 이름 수정
    private func GoalNameEditGroup(text: Binding<String>) -> some View {
        TextField("수정할 목표 이름을 입력하세요", text: text)
            .textStyle(.medium20)
            .foregroundStyle(.black1)
            .padding(.horizontal, 27)
            .frame(height: 56)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            stops: [
                                .init(color: .gradprimary2, location: 0.0),
                                .init(color: .primary1, location: 0.15)
                            ],
                            startPoint: UnitPoint(x: 0.02, y: 0.02),
                            endPoint: UnitPoint(x: 1.6, y: 12.0)
                        ),
                        lineWidth: 1.6
                    )
            )

    }
    
    // MARK: - 기간 수정
    private func GoalPeriodEditGroup(
        start: Binding<Date?>,
        end: Binding<Date?>
    ) -> some View {
        
        let startYear = start.wrappedValue.map { Calendar.current.component(.year, from: $0) }
        let endYear   = end.wrappedValue.map { Calendar.current.component(.year, from: $0) }
        
        return VStack(alignment: .center, spacing: 10) {
            HStack(alignment: .center) {
                
                // 시작날짜
                VStack(alignment: .leading, spacing: 1) {
                    Text(startYear.map { String($0).replacingOccurrences(of: ",", with: "") + "년" } ?? "")
                        .textStyle(.semibold14)
                    Text(vm.formatDate(start.wrappedValue))
                        .textStyle(.semibold20)
                }
                .foregroundStyle(.gray444)

                
                Spacer()
                
                // chevron
                Image(systemName: "chevron.right")
                    .resizable()
                    .frame(width: 8, height: 14)
                
                Spacer()
                
                // 끝날짜
                VStack(alignment: .leading, spacing: 1) {
                    Text(endYear.map { String($0).replacingOccurrences(of: ",", with: "") + "년" } ?? "")
                        .textStyle(.semibold14)
                    Text(vm.formatDate(end.wrappedValue))
                        .textStyle(.semibold20)
                }
                .foregroundStyle(.gray444)
                
                
            }
            .padding(.horizontal, 27)
            
            HStack(alignment: .center) {
                // 시작날짜 수정하기 버튼
                Button{
                    // 시작날짜 수정 로직
                    tempStartDate = vm.startDate ?? Date()
                    editingDateType = .start
                    isShowingStartDatePicker = true
                    
                } label: {
                    HStack(alignment: .center) {
                        Text("수정하기")
                            .textStyle(.semibold14)
                            .foregroundStyle(.gray44450)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(.fff)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(.ccc, lineWidth: 1))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // 끝날짜 수정하기 버튼
                Button{
                    // 끝날짜 수정 로직
                    tempEndDate = vm.endDate ?? (vm.startDate ?? Date())
                    editingDateType = .end
                    isShowingEndDatePicker = true
                    
                } label: {
                    HStack(alignment: .center) {
                        Text("수정하기")
                            .textStyle(.semibold14)
                            .foregroundStyle(.gray44450)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(.fff)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(.ccc, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 35)
        }
        .padding(.vertical, 22)
        .background(.fff)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.ccc, lineWidth: 1)
        )
        .cornerRadius(10)
    }

    // MARK: - 목표 비율
    private func GoalRatioGroup(ratio: Binding<Int>) -> some View {
        let goal = myVM.goalData
        
        return VStack(alignment: .leading, spacing: 0) {
            Text("현재 달성률")
                .textStyle(.semibold18)
                .foregroundStyle(.black1)
                .padding(.bottom, 10)
            
            VStack(alignment: .leading, spacing: 15) {
                progressCapsule(
                    title: "성장",
                    color: Color.green2,
                    actual: goal?.currentGrowthRatio ?? 0,
                    target: vm.ratioStep * 10
                )
                progressCapsule(
                    title: "휴식",
                    color: Color.blue1,
                    actual: goal?.currentRestRatio ?? 0,
                    target: (10 - vm.ratioStep) * 10
                )
            }
        }
        .padding(.top, 17)
        .padding(.bottom, 33)
        .padding(.horizontal, 27)
        .background(.ccc20)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.ccc, lineWidth: 1)
        )
        .cornerRadius(10)
    }
    
    @ViewBuilder
    /// 성장/휴식 공통 캡슐 바
    private func progressCapsule(title: String, color: Color, actual: Int, target: Int) -> some View {
        var progress: CGFloat {
            guard target > 0 else { return 0 }
            return min(1.0, CGFloat(Double(actual) / Double(target)))
        }
        
        VStack(alignment: .leading, spacing: 15) {
            Text(title).textStyle(.semibold18)
            Capsule()
                .fill(.ccc20)
                .overlay(alignment: .leading) {
                    GeometryReader { geo in
                        Capsule()
                            .fill(color)
                            .frame(width: geo.size.width * progress)
                        
                        Text("\(actual)%")  // 지금 얼만큼 채웠는지
                            .textStyle(.medium18)
                            .foregroundStyle(.fff50)
                            .padding(.leading, 10)
                            .opacity(progress > 0.1 ? 1 : 0) // 바가 너무 짧으면 텍스트 숨김
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 85.54)
                        .stroke(.ccc, lineWidth: 1)
                )
                .overlay(alignment: .trailing) {
                    // 바 외부 우측 텍스트 (목표 수치)
                    Text("\(target)%")
                        .textStyle(.medium18)
                        .foregroundStyle(.gray888)
                        .padding(.trailing, 10)
                }
                .frame(height: 25)
        }
    }
    
    // MARK: - 목표 비율 수정
    private func GoalRatioEditGroup(ratio: Binding<Int>) -> some View {
        let purplePercent = vm.ratioStep * 10
        let grayPercent = 100 - purplePercent
        
        let purpleLabel = "\(purplePercent)%"
        let grayLabel = "\(grayPercent)%"
        
        return VStack(alignment: .leading, spacing: 0) {
            Button {
                // TODO: 수정 버튼 클릭 (버튼 맞나.................?)
            } label: {
                HStack(alignment: .center) {
                    Text("수정")
                        .textStyle(.semibold18)
                        .foregroundStyle(.primary1)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
                .background(.primary20)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(.primary1, lineWidth: 1))
            }
            .padding(.bottom, 8)
            .buttonStyle(.plain)
            
            Text(vm.goalName)
                .textStyle(.semibold25)
                .foregroundStyle(.black1)
                .padding(.bottom, 24)
            
            HStack (spacing: 7){
                Text("성장")
                    .textStyle(.medium20)
                    .foregroundStyle(.black1)
                
                Text("\(purpleLabel)")
                    .textStyle(.semibold20)
                    .foregroundStyle(.green1)
                
                Spacer()
                
                Text("\(grayLabel)")
                    .textStyle(.semibold20)
                    .foregroundStyle(.blue1)
                
                Text("휴식")
                    .textStyle(.medium20)
                    .foregroundStyle(.black1)
            }
            .padding(.bottom, 2)
            
            // 성장 비율
            GeometryReader { geo in
                let totalWidth = geo.size.width
                let purpleWidth = totalWidth * (CGFloat(vm.ratioStep) / 10.0)

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(LinearGradient(
                                stops: [
                                    .init(color: .blue20339F, location: 0.0),
                                    .init(color: .blue1, location: 0.70)
                                ],
                                startPoint: UnitPoint(x: 0.25, y: 0.5),
                                endPoint: UnitPoint(x: 0.95, y: 0.5)
                            )
                        )
                        .frame(height: 25)

                    RoundedRectangle(cornerRadius: 100)
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: .green425C47, location: 0.0),
                                    .init(color: .green33633D, location: 0.23),
                                    .init(color: .green0A671E, location: 0.4),
                                    .init(color: .green1, location: 1.0)
                                ],
                                startPoint: UnitPoint(x: 0.25, y: 0.5),
                                endPoint: UnitPoint(x: 0.95, y: 0.5)
                            )
                        )
                        .frame(width: purpleWidth, height: 25)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard totalWidth > 0 else {
                                vm.ratioStep = 0
                                return
                            }

                            let ratio = value.location.x / totalWidth
                            let clamped = max(0, min(1, ratio))
                            let next = Int((clamped * 10).rounded())
                            vm.ratioStep = max(0, min(10, next))
                        }
                )
            }
            .frame(height: 25)

        }
        .padding(.top, 18)
        .padding(.bottom, 24)
        .padding(.horizontal, 27)
        .background(.fff)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.ccc, lineWidth: 1)
        )
        .cornerRadius(10)
    }
    
    // MARK: - 날짜 Tuple
    private func dateFromTuple(_ tuple: (year: String, month: String, day: String)?) -> Date? {
        guard let tuple = tuple else { return nil }
        guard
            let y = Int(tuple.year),
            let m = Int(tuple.month),
            let d = Int(tuple.day)
        else { return nil }

        var comp = DateComponents()
        comp.year = y
        comp.month = m
        comp.day = d
        comp.hour = 0
        comp.minute = 0
        comp.second = 0
        comp.timeZone = TimeZone(identifier: "Asia/Seoul")

        return Calendar.current.date(from: comp)
    }
    
    // MARK: - 날짜 수정을 위한 시트
    private func datePickerSheet(
        title: String,
        selection: Binding<Date>,
        range: PartialRangeFrom<Date>? = nil,
        onDone: @escaping () -> Void
    ) -> some View {
        NavigationStack {
            VStack {
                if let range = range {
                    DatePicker("", selection: selection, in: range, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                } else {
                    DatePicker("", selection: selection, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }
                Spacer()
            }
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        onDone()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    GoalEditView()
        .environment(NavigationRouter<MyPageRoute>())
        .environment(GoalSetupViewModel())
        .environment(MyPageViewModel())

}
