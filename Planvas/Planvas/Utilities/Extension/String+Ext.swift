import Foundation

// MARK: - 서버에서 오는 문자열 튜플로 바꾸기
extension String {
    func toDateTuple() -> (year: String, month: String, day: String)? {
        let array = self.split(separator: "-").map { String($0) }
        
        guard array.count == 3,
              let y = Int(array[0]),
              let m = Int(array[1]),
              let d = Int(array[2]) else { return nil }
        
        return (String(y), String(m), String(d))
    }
}
