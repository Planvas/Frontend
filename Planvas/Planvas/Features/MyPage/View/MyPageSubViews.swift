import SwiftUI

// MARK: - 프로필
struct ProfileView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Image("logo")
            
            HStack {
                Image("profile")
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("김지수")
                            .textStyle(.semibold20)
                        Text("님")
                            .textStyle(.regular18)
                    }
                    Text("밸런스 챌린저(임시)")
                        .foregroundStyle(Color.white)
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.primary1)
                        )
                }
                Spacer()
            }
        }
        .frame(width: 350)
    }
}

// MARK: - 목표
struct goalCardView: View {
    @ObservedObject var viewModel: MyPageViewModel
    
    var body: some View {
        
        if let start = viewModel.startDate, let end = viewModel.endDate  {
            VStack(alignment: .leading, spacing: 15) {
                Text("현재 목표 기간").textStyle(.semibold18)
                
                // 날짜 섹션
                HStack(spacing: 20) {
                    dateVStack(year: start.year, month: start.month, day: start.day)
                    Image(systemName: "chevron.right")
                    dateVStack(year: end.year, month: end.month, day: end.day)
                }
                
                Divider().frame(height: 1)
                
                // TODO: - 서버에서 목표/현재 성장/휴식률 받아오도록 수정
                // 성장 & 휴식 섹션
                VStack(alignment: .leading, spacing: 15) {
                    progressCapsule(title: "성장", color: Color.green2)
                    progressCapsule(title: "휴식", color: Color.blue1)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .gray888.opacity(0.25), radius: 10, x: 2, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray888, lineWidth: 0.3)
            )
            .frame(width: 350)
        }
    }
    
    @ViewBuilder
    /// 성장/휴식 공통 캡슐 바
    private func progressCapsule(title: String, color: Color) -> some View {
        let target = 70
        let actual = 40
        var progress: CGFloat {
            guard target > 0 else { return 0 }
            return min(1.0, CGFloat(Double(actual) / Double(target)))
        }
        
        VStack(alignment: .leading, spacing: 15) {
            Text(title).textStyle(.semibold18)
            Capsule()
                .fill(Color.bar2)
                .overlay(alignment: .leading) {
                    GeometryReader { geo in
                        Capsule()
                            .fill(color)
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 25)
        }
    }

    /// 날짜 표시
    private func dateVStack(year: String, month: String, day: String) -> some View {
        VStack(alignment:.leading) {
            Text("\(year)년").textStyle(.semibold14)
            Text("\(month)월 \(day)일").textStyle(.semibold20)
        }
        .frame(minWidth: 90, minHeight: 50)
        .foregroundStyle(Color.gray444)
    }
}

// MARK: - 상세 페이지 뷰
struct DetailPageView: View {
    @Environment(NavigationRouter<MyPageRoute>.self) var router
    
    var body: some View {
        VStack(spacing: 40) {
           MenuSection("목표 및 활동 관리") {
               MenuButton(title: "현재 목표 수정하기", desc: "비율 및 기간 변경") {
                   router.push(.mainPage)
               }
               MenuButton(title: "지난 시즌 리포트", desc: "히스토리 모아보기") {
                   router.push(.pastReportPage)
               }
           }
           MenuSection("연동 및 알림") {
               MenuButton(title: "캘린더 연동 설정", desc: "구글 캘린더 관리") {
                   router.push(.calenderPage)
               }
               MenuButton(title: "알림 및 리마인더", desc: "D-day 및 완료 알림") {
                   router.push(.alarmPage)
               }
            }
            MenuSection("서비스 정보") {
                DetailPage(title: "로그아웃", description: nil)
            }
        }
        .padding(.horizontal, 0)
    }
}
