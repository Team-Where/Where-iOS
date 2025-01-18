//
//  String.swift
//  Where
//
//  Created by 이현호 on 12/30/24.
//

extension String {
    // 문자열에 이모지가 포함되어 있는지 확인
    var containsEmoji: Bool {
        for character in self {
            if character.isEmoji {
                return true
            }
        }
        return false
    }
}

extension Character {
    // 한 문자가 이모지인지 여부를 확인
    var isEmoji: Bool {
        guard let scalar = self.unicodeScalars.first else { return false }
        return scalar.isEmoji
    }
}

extension UnicodeScalar {
    // 이모지 여부를 확인
    var isEmoji: Bool {
        return (self.value >= 0x1F600 && self.value <= 0x1F64F) || // Emoticons
               (self.value >= 0x1F300 && self.value <= 0x1F5FF) || // Miscellaneous Symbols and Pictographs
               (self.value >= 0x1F680 && self.value <= 0x1F6FF) || // Transport and Map Symbols
               (self.value >= 0x1F700 && self.value <= 0x1F77F) || // Alchemical Symbols
               (self.value >= 0x1F780 && self.value <= 0x1F7FF) || // Geometric Shapes Extended
               (self.value >= 0x1F800 && self.value <= 0x1F8FF) || // Supplemental Symbols and Pictographs
               (self.value >= 0x1F900 && self.value <= 0x1F9FF) || // Supplemental Symbols and Pictographs
               (self.value >= 0x1FA00 && self.value <= 0x1FA6F) || // Chess Symbols
               (self.value >= 0x1FA70 && self.value <= 0x1FAFF) || // Symbols and Pictographs Extended
               (self.value >= 0x2600 && self.value <= 0x26FF) ||   // Miscellaneous Symbols
               (self.value >= 0x2700 && self.value <= 0x27BF) ||   // Dingbats
               (self.value == 0x2B50) ||                         // Star
               (self.value == 0x2B06) ||                         // Upwards Button
               (self.value == 0x2B07)                           // Downwards Button
    }
}
