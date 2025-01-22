//
//  AthentificationState.swift
//  Where
//
//  Created by Swain Yun on 1/22/25.
//

import Foundation

/// 이메일 인증 및 유효성 검증 과정의 상태
enum EmailValidationState {
    /// 이메일 인증 전
    ///
    /// 인증코드 요청하기 전의 상태를 나타냅니다.
    case beforeValidate
    
    /// 인증코드 전송 전 이메일 유효성 검사 실패
    ///
    /// 이메일 유효성 검사에 실패하면 서버에서는 인증코드를 전송하지 않습니다.
    case invalid
    /// 인증코드 전송 전 이메일 유효성 검사 성공
    ///
    /// 이메일 유효성 검사에 성공하면 서버에서는 인증코드를 전송합니다.
    case valid
}

/// 인증코드 유효성 검증 과정의 상태
enum AuthorizationCodeValidationState {
    /// 인증코드 제출 전
    ///
    /// 인증코드를 최초 제출하기 전의 상태입니다.
    case beforeValidate
    
    /// 인증 시간 만료
    ///
    /// 인증코드 제출 마감 시간이 초과된 상태입니다.
    case timeout
    
    /// 인증코드 유효성 검사 실패
    ///
    /// 잘못된 인증코드를 제출한 상태입니다.
    case invalid
    
    /// 인증코드 유효성 검사 성공
    ///
    /// 제출한 인증코드의 유효성이 입증된 상태입니다.
    /// 비밀번호 설정 단계로 넘어갈 수 있습니다.
    case valid
}

/// 비밀번호 유효성 검증 과정의 상태
enum PasswordValidationState {
    /// 비밀번호 유효성 검증 전
    case beforeValidate
    /// 비밀번호 유효성 검증 후 성공
    case valid
    /// 비밀번호 유효성 검증 후 실패
    case invalid
}

/// 비밀번호 재입력 과정의 상태
enum PasswordComparisonResult {
    /// 비밀번호를 재입력하지 않았을 경우의 상태입니다.
    case unknown
    /// 입력한 두 비밀번호가 같은 상태입니다.
    case same
    /// 입력한 두 비밀번호가 다른 상태입니다.
    case different
}
