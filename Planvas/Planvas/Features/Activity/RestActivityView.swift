//
//  RestActivityView.swift
//  Planvas
//
//  Created by 최우진 on 1/29/26.
//

import SwiftUI   // SwiftUI 프레임워크 임포트

// 휴식 활동 메인 화면 View 정의
struct RestActivityView: View {

    // MARK: - 화면 상태 변수들

    @State private var searchText: String = ""     // 검색창에 입력되는 텍스트 상태
    @State private var onlyAvailable: Bool = false // "가능한 일정만 보기" 토글 상태

    @State private var selectedIndex: Int = 0      // 선택된 관심 분야 인덱스
    @State private var extraCount: Int = 2         // 선택된 관심 분야 외 추가 개수
    @State private var chooseText: String = "취미/여가" // 현재 선택된 관심 분야 텍스트
    
    @State private var goCart: Bool = false // 장바구니 이동 변수
    
    @State private var showActivitySheet: Bool = false // 바텀시트 표시 여부
    @State private var goGrowth: Bool = false          // 성장활동으로 이동 트리거
    
    // MARK: - 휴식 카테고리 더미 데이터
    private let restCategories: [String] = [
        "전체",
        "취미/여가",
        "여행",
        "운동/건강",
        "문화/예술"
    ]


    // MARK: - 휴식 더미 데이터

    private let restDummyActivities: [Activity] = [
        Activity(
            title: "도자기 공방\n원데이 클래스",  // 활동 제목
            title2: "도자기 공방\n원데이 클래스",  // 활동 제목
            growth: 10,                          // 성장 포인트
            dday: "상시",                             // D-Day 값
            badgeText: "일정 가능",              // 뱃지 텍스트
            badgeType: .available,               // 뱃지 타입
            tipTag: nil,                         // 팁 태그 없음
            tipText: nil,                         // 팁 내용 없음
            imageName: "성장활동사진1"
        ),
        Activity(
            title: "서울 민속 박물관\n겨울 특별전",
            title2: "서울 민속 박물관\n겨울 특별전",
            growth: 10,
            dday: "1/1~3/31",
            badgeText: "일정 가능",
            badgeType: .available,
            tipTag: nil,
            tipText: nil,
            imageName: nil
        ),
        Activity(
            title: "템플스테이 일주일 살기\n청년 여행비 지원\n힐링 프로그램",
            title2: "템플스테이 일주일 살기\n청년 여행비 지원\n힐링 프로그램",
            growth: 30,
            dday: "1/5~1/12",
            badgeText: "일정 겹침",
            badgeType: .conflict,
            tipTag: "Tip",
            tipT: "[카페 알바]",
            tipText: "일정과 겹쳐요!",
            imageName: nil
        ),
        Activity(
            title: "템플스테이 일주일 살기\n청년 여행비 지원\n힐링 프로그램",
            title2: "템플스테이 일주일 살기\n청년 여행비 지원\n힐링 프로그램",
            growth: 30,
            dday: "1/21~1/28",
            badgeText: "일정 주의",
            badgeType: .caution,
            tipTag: "Tip",
            tipT: "[카페 알바]",
            tipText: "일정이 있어요! 시간을 쪼개서 계획해 보세요",
            imageName: nil
        )
    ]

    // 화면에 표시될 UI 구성
    var body: some View {
        VStack(spacing: 0) {   // 전체 화면을 세로 스택으로 구성
            
            // MARK: - 상단 헤더 영역
            VStack(spacing: 0) {
                HStack {       // 좌우 배치를 위한 가로 스택
                    
                    Image(systemName: "cart")   // 왼쪽 아이콘 (정렬용 더미)
                        .textStyle(.bold20)     // 커스텀 텍스트 스타일 적용
                        .opacity(0)             // 투명 처리
                        .frame(width: 24, height: 24) // 공간 유지
                    
                    Spacer()    // 좌우 여백 확보
                    
//                    HStack(spacing: 6) {   // 타이틀과 드롭다운 아이콘
//                        Text("휴식 활동") // 화면 타이틀
//                            .textStyle(.semibold22)
//                            .foregroundColor(.black1)
//                        Image(systemName: "chevron.down") // 드롭다운 아이콘
//                            .font(.system(size: 14, weight: .semibold))
//                            .foregroundColor(.black1)
//                    }
                    Button {
                        showActivitySheet = true
                    } label: {
                        HStack(spacing: 10) {
                            Text("휴식 활동")
                                .textStyle(.bold20)
                                .foregroundColor(.black)
                            Image(systemName: "chevron.down")
                                .textStyle(.bold20)
                                .foregroundColor(.black1)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()    // 좌우 균형 맞추기
                    
                    Button {
                        goCart = true
                    } label: {
                        Image(systemName: "cart")
                            .textStyle(.semibold18)
                            .foregroundColor(.black1)
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 20)   // 하단 여백
            .padding(.horizontal, 20) // 좌우 여백
            
            // MARK: - 검색바 영역
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    
                    ZStack {   // 돋보기 아이콘 배경
                        Circle()
                            .fill(Color.primary1)
                            .frame(width: 42, height: 42)
                        
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 25, weight: .light))
                            .foregroundColor(.fff)
                    }
                    
                    TextField("원하는 활동을 검색하세요", text: $searchText) // 검색 입력창
                        .textStyle(.medium18)
                        .foregroundColor(.black1)
                        .padding(.leading, 15)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    
                    if !searchText.isEmpty {   // 검색어가 있을 때만 표시
                        Button(action: { searchText = "" }) { // 검색어 초기화
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color.black20)
                        }
                        .padding(.trailing, 12)
                    }
                }
                .frame(maxWidth: .infinity)   // 가로 최대 확장
                .frame(height: 42)             // 높이 고정
                .background(Color.fff)
                .clipShape(Capsule())          // 캡슐 형태
                .overlay(
                    Capsule()
                        .stroke(Color.primary1, lineWidth: 1) // 테두리
                )
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 16)
            
            // MARK: - 관심 분야 칩 영역
            VStack(alignment: .leading, spacing: 0) {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(restCategories, id: \.self) { category in
                            Text(category)
                                .textStyle(.medium16)
                                .foregroundColor(Color(.gray44450))   // #444 50%
                                .frame(height: 40)
                                .padding(.horizontal, 10)
                                .overlay(
                                    Capsule()
                                        .stroke(Color(.ccc), lineWidth: 1.2)
                                )
                        }
                    }
                    .padding(.horizontal, 20) // 좌우 20씩 띄어줌
                }
                
                Spacer().frame(height: 15) // 구분선이랑 15만큼 띄우고
                
                Rectangle()   // 구분선
                    .fill(Color.line)
                    .frame(height: 10) // 구분선 높이 10
            }
            
            Spacer().frame(height: 20) // 구분선이랑 20만큼 띄우고
            
            // MARK: - 추천 활동 헤더 + 토글
            VStack(spacing: 4) { //휴식 추천활동과 가능한 일정만 보기 4만큼 띄워줌
                HStack {
                    HStack(spacing: 0) {
                        Text("휴식 ")
                            .textStyle(.bold25)
                            .foregroundColor(.primary1)
                        
                        Text("추천활동")
                            .textStyle(.semibold25)
                            .foregroundColor(.black1)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20) // 휴식 추천활동 좌우 20 간격
                
                // 가능한 일정만 보기
                HStack {
                    Spacer() //왼쪽 공간 주고
                    
                    HStack(spacing: 8) { //글씨랑 버튼이랑 간격 8
                        Text("가능한 일정만 보기")
                            .textStyle(.medium16)
                            .foregroundColor(.primary1)
                        
                        PlanvasToggle(isOn: $onlyAvailable)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer().frame(height: 16) //가능한 일정 보기랑 아래 일정 카드 간격 16
            
            // MARK: - 활동 카드 리스트 영역
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 8) {
                            ForEach(listAvailable) { item in
                                RestActivityCardView(item: item)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer().frame(height: 20) //위에랑 회색 선 기준 간격 20
                    
                    // 회색 구분 바
                    Rectangle()
                        .fill(Color.line)
                        .frame(height: 10)
                    
                    Spacer().frame(height: 25) //아래랑 회색 선 기준 간격 20
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 8) {
                            ForEach(listOthers) { item in
                                RestActivityCardView(item: item)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .background(Color.fff)
        
        .navigationDestination(isPresented: $goCart) { CartView() }
        .navigationDestination(isPresented: $goGrowth) { ActivityView() }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showActivitySheet) {
            VStack(spacing: 0) {

                Capsule()
                    .fill(Color.gray.opacity(0.35))
                    .frame(width: 44, height: 5)
                    .padding(.top, 10)
                    .padding(.bottom, 14)

                // 성장 활동 -> ActivityView로 이동
                Button {
                    showActivitySheet = false
                    goGrowth = true
                } label: {
                    HStack {
                        Text("성장 활동")
                            .textStyle(.semibold20)
                            .foregroundColor(.black1)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 78)
                }
                .buttonStyle(.plain)

                Rectangle()
                    .fill(Color.line)
                    .frame(height: 1)

                // 휴식 활동 -> 현재 화면이니까 닫기만
                Button {
                    showActivitySheet = false
                } label: {
                    HStack {
                        Text("휴식 활동")
                            .textStyle(.semibold20)
                            .foregroundColor(.black1)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 78)
                }
                .buttonStyle(.plain)

                Rectangle()
                    .fill(Color.line)
                    .frame(height: 1)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .background(Color.fff)
            .presentationDetents([.height(248)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(0)
            .presentationBackground(Color.fff)
            .ignoresSafeArea(.container, edges: .horizontal)
        }

    }

    // MARK: - 검색 + 토글 필터링 로직

    private var filteredRestActivities: [Activity] {
        var result = restDummyActivities   // 전체 데이터 복사

        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !keyword.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(keyword) }
        }

        if onlyAvailable {
            result = result.filter { $0.badgeType != .conflict }
        }

        return result
    }

    private var listAvailable: [Activity] {
        filteredRestActivities.filter { $0.badgeType == .available }
    }

    private var listOthers: [Activity] {
        filteredRestActivities.filter { $0.badgeType != .available }
    }
}
    

// MARK: - 휴식 활동 카드 View
// 휴식 활동 카드 하나를 표현하는 View
struct RestActivityCardView: View {

    // 카드에 표시할 Activity 데이터
    let item: Activity

    // 카드 UI 구성
    var body: some View {

        // 카드 내부 요소들을 세로로 배치하는 VStack
        VStack(alignment: .leading, spacing : 0) {
            // 상단 이미지 영역 + 우상단 뱃지
            ZStack(alignment: .topTrailing) {

                // 이미지 or 회색 박스
                Group {
                    if let imageName = item.imageName, !imageName.isEmpty {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.ccc
                    }
                }
                .frame(width: 175, height: 111)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.ccc, lineWidth: 1)
                )
                .clipped()

                Text(item.badgeText)
                    .textStyle(.semibold14)
                    .foregroundColor(.fff)
                    .frame(width: 83, height: 25)          // 뱃지 고정 사이즈
                    .background(item.badgeType.color)      // 뱃지 배경색
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 7)                      // 위에서 7 안쪽
                    .padding(.trailing, 7)                 // 오른쪽에서 7 안쪽
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.ccc, lineWidth: 0.5)
                    )
            }

            
            Spacer().frame(height: 25) //회색이랑 글씨 간격 25
            

            // 활동 제목 텍스트
            Text(item.title)                            // Activity 제목 표시
                .textStyle(.semibold16)                 // 제목용 텍스트 스타일
                .foregroundColor(.black1)                // 텍스트 색상

            Spacer()
            

            // D-Day와 성장 수치를 가로로 배치
            HStack {

                // D-Day 표시
                Text("\(item.dday)")                  // D-Day 텍스트
                    .textStyle(.medium14)             // 텍스트 스타일
                    .foregroundColor(.fff)            // 텍스트 색상 흰색
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .frame(minHeight: 27)
                    .background(Color.primary1)         // 배경 색상
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                // D-Day와 성장 텍스트 사이 여백
                Spacer()

                // 성장 수치 표시
                Text("성장 +\(item.growth)")            // 성장 포인트 텍스트
                    .textStyle(.semibold14)             // 텍스트 스타일
                    .foregroundColor(.primary1)         // 포인트 강조 색상
            }

            // 팁 정보가 있을 경우에만 표시
            if let tipText = item.tipText, let tipTag = item.tipTag, let tipT = item.tipT {
                Spacer().frame(height: 15) //디데이랑 팁박스 간격
                ZStack {
                    // 바탕(흰색) + 빨간 테두리
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.fff)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(item.badgeType.color, lineWidth: 1.5)
                        )

                    VStack(spacing: 10) {

                        // Tip 태그(상단, 가운데)
                        Text(tipTag)
                            .textStyle(.semibold14)
                            .foregroundColor(.fff)
                            .frame(width: 44, height: 21)
                            .background(item.badgeType.color)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .padding(.top, 8)
                        
                        
                        // [] 강조 문구
                        Text(tipT)
                            .textStyle(.bold14)
                            .foregroundColor(.black1)
                            .padding(.horizontal, 8)

                        // 아래 문구(가운데)
                        Text(tipText)
                            .textStyle(.medium14)
                            .foregroundColor(.black1)
                            .padding(.horizontal, 8)

                        Spacer(minLength: 0)
                    }
                }
                .frame(width: 175, height: 81)
            }

        }
        .padding(12)                                    // 카드 내부 전체 여백
        .frame(width: 195)                 // 카드 전체 크기
        .background(Color.fff)                        // 카드 배경 색상
        .clipShape(RoundedRectangle(cornerRadius: 16))  // 카드 모서리 둥글게 처리
        .overlay(                                       // 카드 테두리 추가
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}
// 1) 커스텀 토글(스위치) 뷰
struct PlanvasToggle: View {
    @Binding var isOn: Bool

    private let toggleWidth: CGFloat = 52
    private let toggleHeight: CGFloat = 26
    private let knobSize: CGFloat = 18
    private let padding: CGFloat = 4

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                isOn.toggle()
            }
        } label: {
            ZStack(alignment: .leading) {

                // 배경(ON: primary1 / OFF: 회색)
                Capsule()
                    .fill(isOn ? Color.primary1 : Color.primary1)
                    .frame(width: toggleWidth, height: toggleHeight)

                // 흰 동그라미(18x18), 좌우 4px 패딩
                Circle()
                    .fill(Color.fff)
                    .frame(width: knobSize, height: knobSize)
                    .offset(x: isOn ? (toggleWidth - knobSize - padding * 2) : 0)
                    .padding(.leading, padding)
            }
            .frame(width: toggleWidth, height: toggleHeight)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("가능한 일정만 보기")
        .accessibilityValue(isOn ? "ON" : "OFF")
    }
}

// 프리뷰 설정
#Preview {
    NavigationStack {
        RestActivityView()
    }
}

