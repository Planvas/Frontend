//
//  ActivityView.swift
//  Planvas
//
//  Created by 정서영 on 1/14/26.
//

import SwiftUI

struct ActivityView: View {

    // MARK: - State Properties (화면 상태 관리)
    @State private var searchText: String = "" // 검색창에 입력되는 텍스트 저장
    @State private var selectedIndex: Int = 0 // 현재 선택된 인덱스 (확장성용)
    @State private var onlyAvailable: Bool = true // '가능한 일정만 보기' 토글 상태
    @State private var extraCount: Int = 2   // 관심 분야 칩 옆에 표시될 추가 카테고리 수 (+N)
    @State private var chooseText: String = "개발/IT" // 검색창에 입력되는 텍스트 저장

    var body: some View {
        VStack(spacing: 0) { // 전체 뷰를 수직으로 배치, 기본 간격은 0

            // MARK: - 상단 헤더 (네비게이션 바 형태)
            VStack(spacing: 0) {
                HStack {
                    //성장 활동을 가운데 오게 하기 위해서 장바구니와 같은 크기를 투명하게 해서 배치
                    Image(systemName: "cart")
                                .font(.system(size: 20))
                                .opacity(0) // 투명하게 처리
                                .frame(width: 24, height: 24)
                    
                    Spacer()

                    // 중앙: 타이틀 및 드롭다운 아이콘
                    HStack(spacing: 6) {
                        Text("성장 활동") // 메인 타이틀 -> 글씨 사이즈 모르겠음 일단 대강 22로
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                        Image(systemName: "chevron.down") // 카테고리 전환 등을 암시하는 아이콘
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                    }

                    Spacer()

                    // 오른쪽: 장바구니 아이콘
                    Image(systemName: "cart")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .frame(width: 24, height: 24)
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
                            .fill(Color(white: 0.3)) // 기획안의 진한 회색 (약 70% dark)
                            .frame(width: 42, height: 42)

                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 25, weight: .light))
                            .foregroundColor(.white)
                    }
                    

                    // 2. 텍스트 입력 필드
                    TextField("검색어를 입력해주세요", text: $searchText)
                        .font(.system(size: 15))
                        .foregroundColor(.black)
                        .padding(.leading, 15) // 아이콘과 텍스트 사이 간격 15px
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)

                    // 3. 지우기 버튼 (텍스트가 있을 때만)
                    if !searchText.isEmpty {
                        Button(action: { self.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        .padding(.trailing, 12)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 42) // 353 x 42 규격
                .background(Color.white)
                .clipShape(Capsule()) // 완벽한 타원형(Capsule) 적용
                .overlay(
                    // 테두리 선 (기획안처럼 명확한 회색)
                    Capsule()
                        .stroke(Color.black.opacity(0.35), lineWidth: 1)
                )
                .padding(.horizontal, 20) // 외부 좌우 여백
            }
            .padding(.bottom, 31)

            // MARK: - 관심 분야 영역 (타이틀 + 칩 스크롤)
            VStack(alignment: .leading, spacing: 0) { // 왼쪽 정렬

                Text("관심 분야") // 섹션 타이틀
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)

                Spacer()
                    .frame(height: 10) // 타이틀과 칩 사이 간격

                // 가로 스크롤이 가능한 칩 그룹
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {

                        // 선택된 상태의 칩 (개발/IT + 배지)
                        HStack(spacing: 6) {
                            Text("\(chooseText)") // 카테고리명
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)

                            // 선택된 항목 외의 개수를 표시하는 배지 (+N)
                            Text("+\(extraCount)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.purple)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.purple) // 강조색(보라색) 배경
                        .clipShape(Capsule())

                        // 구분선 아이콘
                        Text("|")
                            .foregroundColor(.gray.opacity(0.5))

                        // 나머지 비활성 상태의 칩들 (반복되는 형태)
                        Text("전체")
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .foregroundColor(.gray)
                            .overlay(Capsule().stroke(Color.gray.opacity(0.4)))

                        Text("공모전")
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .foregroundColor(.gray)
                            .overlay(Capsule().stroke(Color.gray.opacity(0.4)))

                        Text("학회/동아리")
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .foregroundColor(.gray)
                            .overlay(Capsule().stroke(Color.gray.opacity(0.4)))

                        Text("대외활동")
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .foregroundColor(.gray)
                            .overlay(Capsule().stroke(Color.gray.opacity(0.4)))

                        Text("어학/자격증")
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .foregroundColor(.gray)
                            .overlay(Capsule().stroke(Color.gray.opacity(0.4)))

                        Text("인턴십")
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .foregroundColor(.gray)
                            .overlay(Capsule().stroke(Color.gray.opacity(0.4)))

                        Text("교육/강연")
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .foregroundColor(.gray)
                            .overlay(Capsule().stroke(Color.gray.opacity(0.4)))
                    }
                    .padding(.leading, 20)  // 스크롤 시작점 여백
                    .padding(.trailing, 20) // 스크롤 끝점 여백
                    .padding(.vertical, 2)  // 테두리가 잘리지 않게 위아래 여백
                }

                Spacer()
                    .frame(height: 15) // 칩 영역과 하단 구분선 사이 간격

                // MARK: - 섹션 구분용 배경 (회색 띠)
                Rectangle()
                    .fill(Color.black.opacity(0.06))
                    .frame(height: 10)
            }

            Spacer()
                .frame(height: 20) // 구분 배경과 추천 섹션 사이 간격

            // MARK: - 추천 활동 헤더 (제목 + 토글 버튼)
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    // '성장 추천활동' 타이틀 (색상 혼합)
                    HStack(spacing: 0) {
                        Text("성장 ")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.purple) // '성장'만 보라색
                        Text("추천활동")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }

                    Spacer()

                    // 필터 토글 영역
                    HStack(spacing: 12) {
                        Text("가능한 일정만 보기")
                            .font(.system(size: 14))
                            .foregroundColor(.purple)

                        Toggle("", isOn: $onlyAvailable)
                            .labelsHidden() // 토글 기본 라벨 숨김 (커스텀 텍스트 사용 중이므로)
                    }
                }
                .padding(.horizontal, 20)
            }

            Spacer()
                .frame(height: 28) // 헤더와 검색 결과 없음 텍스트 사이 간격

            // MARK: - 결과가 없을 때 표시되는 뷰
            VStack(spacing: 8) {
                Text("검색 결과 없음")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black.opacity(0.8))

                Text("검색어가 맞는지 다시 한 번 확인해주세요")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity) // 가로 전체 너비 확보
            .padding(.top, 30) // 상단 여백 추가

            Spacer(minLength: 0) // 남은 하단 공간을 모두 채움
        }
        .background(Color.white) // 전체 배경색 흰색
    }
    
}

// 미리보기 화면
#Preview {
    ActivityView()
}
