//
//  ActivityView.swift
//  Planvas
//
//  Created by 정서영 on 1/14/26.
//

import SwiftUI

struct ActivityView: View {
    
    // MARK: - State Properties (화면 상태 관리)
    @StateObject private var vm = ActivityExploreViewModel()
    
    @State private var onlyAvailable: Bool = false // "가능한 일정만 보기" 토글 상태
    
    @State private var selectedIndex: Int = 0 // 현재 선택된 인덱스 (확장성용)ㅎ
    @State private var extraCount: Int = 2   // 관심 분야 칩 옆에 표시될 추가 카테고리 수 (+N)
    @State private var chooseText: String = "개발/IT" // 검색창에 입력되는 텍스트 저장
    
    @State private var goCart: Bool = false // 장바구니 이동 변수
    
    //v로 휴식활동 성장활동 이동 변수
    @State private var showActivitySheet: Bool = false   // 바텀시트 표시 여부
    @State private var goRest: Bool = false              // 휴식활동으로 이동 트리거
    
    @State private var showInterestSheet: Bool = false
    @State private var selectedInterests: Set<String> = ["개발/IT"]   // 저장용(선택 확정값)
    @State private var tempSelectedInterests: Set<String> = []        // 시트에서 편집용

    private let interestOptions: [String] = [
        "개발/IT", "마케팅", "디자인", "경영/사무", "과학/공학", "경제/금융", "영상/콘텐츠", "기획/마케팅/광고"
    ]

    private let categoryChips: [String] = [
        "전체", "공모전", "학회/동아리", "대외활동", "어학/자격증", "인턴십", "교육/강연"
    ]
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) { // 전체 뷰를 수직으로 배치, 기본 간격은 0
                
                // MARK: - 상단 헤더 (네비게이션 바 형태)
                VStack(spacing: 0) {
                    HStack {
                        //성장 활동을 가운데 오게 하기 위해서 장바구니와 같은 크기를 투명하게 해서 배치
                        Image(systemName: "cart")
                            .textStyle(.bold20)
                            .opacity(0) // 투명하게 처리
                            .frame(width: 24, height: 24)
                        
                        Spacer()
                        

                        Button {
                            showActivitySheet = true
                        } label: {
                            HStack(spacing: 10) {
                                Text("성장 활동")
                                    .textStyle(.bold20)
                                    .foregroundColor(.black)
                                Image(systemName: "chevron.down")
                                    .textStyle(.bold20)
                                    .foregroundColor(.black1)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        
                        Spacer()
                        
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
                .padding(.bottom, 20) // 헤더 하단과 검색바 사이의 외부 간격 20
                .padding(.horizontal, 20) // 전체 좌우 여백 20
                
                // MARK: - 검색바 영역
                VStack(spacing: 0) {
                    HStack(spacing: 0) { // 내부 간격을 세밀하게 조정하기 위해 0으로 설정
                        
                        // 1. 검색 아이콘 (원형 배경 + 돋보기)
                        ZStack {
                            Circle()
                                .fill(.gray444)
                                .frame(width: 42, height: 42)
                            
                            Image(systemName: "magnifyingglass")
                                .textStyle(.semibold22)
                                .foregroundColor(.white)
                        }
                        
                        
                        // 2. 텍스트 입력 필드
                        TextField("검색어를 입력해주세요", text: $vm.searchText)
                            .textStyle(.medium18)
                            .foregroundColor(.black1)
                            .padding(.leading, 15) // 아이콘과 텍스트 사이 간격 15px
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                        
                        // 3. 지우기 버튼 (텍스트가 있을 때만)
                        if !vm.searchText.isEmpty {
                            Button(action: { vm.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.black20)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 42) // 353 x 42 규격
                    .background(Color.fff)
                    .clipShape(Capsule()) // 완벽한 타원형(Capsule) 적용
                    .overlay(
                        Capsule()
                            .stroke(Color.gray444, lineWidth: 1.5)
                    )
                    .padding(.horizontal, 20) // 외부 좌우 여백
                }
                .padding(.bottom, 31)
                
                // MARK: - 관심 분야 영역 (타이틀 + 칩 스크롤)
                VStack(alignment: .leading, spacing: 0) { // 왼쪽 정렬
                    
                    Text("관심 분야") // 섹션 타이틀
                        .textStyle(.semibold20)
                        .foregroundColor(.black1)
                        .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 10) // 타이틀과 칩 사이 간격
                    
                    // 가로 스크롤이 가능한 칩 그룹
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            Button {
                                tempSelectedInterests = selectedInterests   // 열 때 현재 선택값 복사
                                showInterestSheet = true
                            } label: {
                                HStack(spacing: 6) {
                                    Text("\(chooseText)")
                                        .textStyle(.semibold14)
                                        .foregroundColor(.white)

                                    Text("+\(extraCount)")
                                        .textStyle(.semibold14)
                                        .foregroundColor(.primary1)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.white)
                                        .clipShape(Capsule())
                                }
                                .padding(.horizontal, 11.5)
                                .padding(.vertical, 10.5)
                                .background(.primary1)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                            }
                            .buttonStyle(.plain)

                            
                            // 구분선 아이콘
                            Text("|")
                                .foregroundColor(.gray.opacity(0.5))
                            
                            ForEach(categoryChips, id: \.self) { title in
                                Text(title)
                                    .padding(.horizontal, 11.5)
                                    .padding(.vertical, 10.5)
                                    .foregroundColor(.gray44450)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color.ccc, lineWidth: 1.2)
                                    )
                            }
                            
                        }
                        .padding(.leading, 20)  // 스크롤 시작점 여백
                        .padding(.trailing, 20) // 스크롤 끝점 여백
                    }
                    
                    Spacer().frame(height: 15) // 칩 영역과 하단 구분선 사이 간격
                    
                    // MARK: - 섹션 구분용 배경 (회색 띠)
                    Rectangle()
                        .fill(Color.line)
                        .frame(height: 10)
                }
                
                Spacer().frame(height: 20) // 구분 배경과 추천 섹션 사이 간격
                
                
                // MARK: - 성장 추천활동 헤더 전체
                VStack(spacing: 8) {
                    // MARK: - 제목 영역
                    HStack {
                        HStack(spacing: 0) {
                            Text("성장 ")
                                .textStyle(.bold25)
                                .foregroundColor(.primary1)
                            
                            Text("추천활동")
                                .textStyle(.semibold25)
                                .foregroundColor(.black1)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - 필터 토글 영역
                    HStack {
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Text("가능한 일정만 보기")
                                .textStyle(.medium16)
                                .foregroundColor(.primary1)
                            
                            PlanvasToggle(isOn: $onlyAvailable)

                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                    .frame(height: 17)
                
                // MARK: - 결과 영역
                if vm.filteredActivities.isEmpty {
                    
                    // MARK: - 결과가 없을 때 표시되는 뷰
                    VStack(spacing: 8) {
                        Text("검색 결과 없음")
                            .textStyle(.semibold20)
                            .foregroundColor(Color.gray444)
                        
                        Text("검색어가 맞는지 다시 한 번 확인해주세요")
                            .textStyle(.medium14)
                            .foregroundColor(.gray444)
                    }
                    .frame(maxWidth: .infinity)   // 가로 전체 너비
                    .padding(.top, 30)             // 상단 여백
                    
                    Spacer(minLength: 0)           // 아래 공간 채우기
                    
                } else {
                    
                    // MARK: - 결과가 있을 때 카드 리스트
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(vm.filteredActivities) { item in
                                NavigationLink {
                                    ActivityDetailView(item: item)   // 상세는 한 파일/한 뷰
                                } label: {
                                    ActivityCardView(item: item)
                                }
                                .buttonStyle(.plain)
                            }

                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
                
                
            }
            .background(Color.fff)
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $goCart) { CartView() }
            .navigationDestination(isPresented: $goRest) { RestActivityView() }
            .sheet(isPresented: $showActivitySheet) {
                VStack(spacing: 0) {
                    
                    // 손잡이
                    Capsule()
                        .fill(Color.gray.opacity(0.35))
                        .frame(width: 44, height: 5)
                        .padding(.top, 10)
                        .padding(.bottom, 14)
                    
                    // 성장 활동
                    Button {
                        showActivitySheet = false
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
                    
                    // 구분선 1px
                    Rectangle()
                        .fill(Color.line)
                        .frame(height: 1)
                    
                    // 휴식 활동
                    Button {
                        showActivitySheet = false
                        goRest = true
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
                    
                    // 아래 구분선 1px (두번째 사진처럼)
                    Rectangle()
                        .fill(Color.line)
                        .frame(height: 1)
                    
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                .background(Color.fff)
                .presentationDetents([.height(248)])
                .presentationDragIndicator(.hidden)
            }
            .sheet(isPresented: $showInterestSheet) {

                VStack(spacing: 0) {

                    // 손잡이(원하면)
                    Capsule()
                        .fill(Color.gray.opacity(0.35))
                        .frame(width: 44, height: 5)
                        .padding(.top, 10)
                        .padding(.bottom, 14)

                    // 상단 타이틀 + 초기화
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("관심 분야")
                                .textStyle(.semibold20)
                                .foregroundColor(.black1)
                            Text("최대 3개 선택 가능")
                                .textStyle(.medium14)
                                .foregroundColor(.gray444)
                        }

                        Spacer()

                        Button {
                            tempSelectedInterests.removeAll()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.clockwise")
                                Text("초기화")
                            }
                            .textStyle(.semibold14)
                            .foregroundColor(.primary1)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .overlay(
                                Capsule().stroke(Color.primary1, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 18)

                    // 칩 그리드(대강)
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ], spacing: 12) {

                        ForEach(interestOptions, id: \.self) { option in
                            let isSelected = tempSelectedInterests.contains(option)

                            Button {
                                if isSelected {
                                    tempSelectedInterests.remove(option)
                                } else {
                                    // 최대 3개 제한
                                    if tempSelectedInterests.count < 3 {
                                        tempSelectedInterests.insert(option)
                                    }
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    // 아이콘은 대강(필요하면 옵션별로 바꿔)
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 6))

                                    Text(option)
                                        .textStyle(.medium14)
                                }
                                .foregroundColor(isSelected ? .white : .black1)
                                .padding(.horizontal, 14)
                                .frame(height: 36)
                                .background(isSelected ? Color.primary1 : Color.fff)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(isSelected ? Color.primary1 : Color.ccc, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    // 적용하기 버튼
                    Button {
                        selectedInterests = tempSelectedInterests

                        // chooseText / extraCount 업데이트(대강 규칙)
                        if let first = selectedInterests.first {
                            chooseText = first
                        }
                        extraCount = max(selectedInterests.count - 1, 0)

                        showInterestSheet = false
                    } label: {
                        Text("적용하기")
                            .textStyle(.semibold18)
                            .foregroundColor(.black1)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.primary1, lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 18)
                }
                .frame(maxWidth: .infinity)
                .background(Color.fff)
                .presentationDetents([.height(853)])
                .presentationDragIndicator(.hidden)
            }

            
            
        }
        
        
    }
}


// 미리보기 화면
#Preview {
    ActivityView()
}
