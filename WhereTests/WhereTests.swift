//
//  WhereTests.swift
//  WhereTests
//
//  Created by Swain Yun on 1/2/25.
//

import Foundation
import Testing

struct WhereTests {
    @Test func 비밀번호_유효성_검사가_정확한지() {
        // given
        // - 조건 충족
        let validPasswords: [String] = [
            "Abcdef12!", "1Secure@Password", "HelloWorld!23", "Test~12345",
            "ValidPassword@2025", "SwiftUI~Rocks1", "MyP@ssw0rd", "Example!123",
            "StringP@ssword!1", "User@Pass123", "Sw@inYun2025", " LetMeIn~123",
        ]
        
        // - 조건 미충족
        let invalidPasswords: [String] = [
            "abcdefg", "ABCDEFGH", "12345678", "Password!",
            "Passw0rd", "!@#12345", "Short!1", "ThisPasswordIsWayTooLong123456!",
            "valid@12", "1234!@", "LetMeIn", "Password123!"
        ]
        
        // when
        func isPasswordValid(_ password: String) -> Bool {
            // 8~32자
            guard (8...32).contains(password.count) else { return false }
            
            // 영문, 숫자, 특수문자("!", "~", "@") 포함
            let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
            let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
            let hasDigits = password.rangeOfCharacter(from: .decimalDigits) != nil
            let hasSpecialCharacters = password.rangeOfCharacter(from: CharacterSet(charactersIn: "!~@")) != nil
            
            return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters
        }
        
        let result1 = validPasswords.allSatisfy { isPasswordValid($0) } // 유효성 검사에서 모두 통과하여 true가 되어야 함
        let result2 = invalidPasswords.allSatisfy { isPasswordValid($0) } // 유효성 검사에서 모두 탈락하여 false가 되어야 함
        
        // then
        #expect(result1 == true && result2 == false)
    }
}
