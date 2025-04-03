import Foundation

extension Date {
    var dateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy HH:mm"
        return formatter.string(from: self)
    }
}
