import Foundation

extension String {
    func isValidNickname() -> Bool {
        let pattern = "^[a-zA-Z0-9가-힣\\-_]{2,8}$"
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: self.utf16.count)
            let matches = regex.matches(in: self, range: range)
            return !matches.isEmpty
        } catch {
            return false
        }
    }
}
