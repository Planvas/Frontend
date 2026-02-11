import SwiftUI

// MARK: - 프로필
struct ProfileView: View {
    var viewModel: MyPageViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Image("logo")
            
            HStack {
                Image("profile")
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(viewModel.userData?.name ?? "사용자")
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
    var viewModel: MyPageViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if let goal = viewModel.goalData, let start = viewModel.goalData?.startTuple, let end = viewModel.goalData?.endTuple  {
                Text("현재 목표 기간").textStyle(.semibold18)
                
                // 날짜 섹션
                HStack(spacing: 20) {
                    dateVStack(year: start.year, month: start.month, day: start.day)
                    Image(systemName: "chevron.right")
                    dateVStack(year: end.year, month: end.month, day: end.day)
                }
                
                Divider().frame(height: 1)
                
                // 성장 & 휴식 섹션
                VStack(alignment: .leading, spacing: 15) {
                    progressCapsule(
                        title: "성장",
                        color: Color.green2,
                        actual: goal.currentGrowthRatio ?? 0,
                        target: goal.growthRatio ?? 0
                    )
                    progressCapsule(
                        title: "휴식",
                        color: Color.blue1,
                        actual: goal.currentRestRatio ?? 0,
                        target: goal.restRatio ?? 0
                    )
                }
            }
            else {
                VStack(spacing:10) {
                    Text("진행 중인 목표가 없습니다")
                        .textStyle(.semibold18)
                        .foregroundColor(.gray444)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
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
                .fill(Color.bar2)
                .overlay(alignment: .leading) {
                    GeometryReader { geo in
                        Capsule()
                            .fill(color)
                            .frame(width: geo.size.width * progress)
                        
                        Text("\(actual)%")
                            .font(.system(size: 14, weight: .bold))
                            .padding(.top, 4)
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                            .opacity(progress > 0.1 ? 1 : 0) // 바가 너무 짧으면 텍스트 숨김
                    }
                }
                .overlay(alignment: .trailing) {
                    // 바 외부 우측 텍스트 (목표 수치)
                    Text("\(target)%")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.trailing, 10)
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
    @EnvironmentObject var container: DIContainer
    @Binding var showCalendarAlert: Bool
    
    var body: some View {
        VStack(spacing: 40) {
           MenuSection("목표 및 활동 관리") {
               MenuButton(title: "현재 목표 수정하기", desc: "비율 및 기간 변경") {
                   router.push(.currentGoalPage)
               }
               MenuButton(title: "지난 시즌 리포트", desc: "히스토리 모아보기") {
                   router.push(.pastReportPage)
               }
           }
           MenuSection("연동 및 알림") {
               MenuButton(title: "캘린더 연동 설정", desc: "구글 캘린더 관리") {
                   showCalendarAlert = true
               }
               MenuButton(title: "알림 및 리마인더", desc: "D-day 및 완료 알림") {
                   router.push(.alarmPage)
               }
            }
            MenuSection("서비스 정보") {
                MenuButton(title: "로그아웃", desc: nil) {
                    AuthManager.shared.logout()
                    container.appState.isLoggedIn = false
                    router.reset()
                    router.push(.loginPage)
                }
            }
        }
        .padding(.horizontal, 0)
    }
}
