import Foundation

// 비교할 두 개의 날짜
let startDate = Date()
let endDate = Calendar.current.date(byAdding: .day, value: 3, to: startDate)!

// 날짜 간의 차이 계산
let calendar = Calendar.current
let components = calendar.dateComponents([.day], from: startDate, to: endDate)

// 날짜 간의 차이가 2일 이상인지 여부 확인
//if let days = components.day, days >= 2 {
//    print("날짜 간의 차이가 2일 이상입니다.")
//} else {
//    print("날짜 간의 차이가 2일 미만입니다.")
//}
extension Date{
    func isOverTwoDays(prevDate:Date) -> Bool{
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: prevDate)
        if let days = components.day, days >= 2 {
            return true
        } else {
            return false
        }
    }
}

print(startDate.isOverTwoDays(prevDate: endDate))
