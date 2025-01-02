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
        return (self.value >= 0x1F600 && self.value <= 0x1F64F) || // 이모티콘
               (self.value >= 0x1F300 && self.value <= 0x1F5FF) || // 기타 기호 및 그림문자
               (self.value >= 0x1F680 && self.value <= 0x1F6FF) || // 교통 및 지도 기호
               (self.value >= 0x1F700 && self.value <= 0x1F77F) || // 연금술 기호
               (self.value >= 0x1F780 && self.value <= 0x1F7FF) || // 확장된 기하학적 도형
               (self.value >= 0x1F800 && self.value <= 0x1F8FF) || // 보충 기호 및 그림문자
               (self.value >= 0x1F900 && self.value <= 0x1F9FF) || // 보충 기호 및 그림문자
               (self.value >= 0x1FA00 && self.value <= 0x1FA6F) || // 체스 기호
               (self.value >= 0x1FA70 && self.value <= 0x1FAFF) || // 확장된 기호 및 그림문자
               (self.value >= 0x2600 && self.value <= 0x26FF) ||   // 기타 기호
               (self.value >= 0x2700 && self.value <= 0x27BF) ||   // 딩뱃 기호
               (self.value == 0x2B50) ||                         // 별 모양
               (self.value == 0x2B06) ||                         // 위쪽 화살표 버튼
               (self.value == 0x2B07)                           // 아래쪽 화살표 버튼
    }
}
