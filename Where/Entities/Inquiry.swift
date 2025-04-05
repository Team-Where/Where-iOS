//
//  Inquiry.swift
//  Where
//
//  Created by Swain Yun on 1/23/25.
//

import UIKit

/// 사용자 문의(질문)
struct Inquiry: Identifiable {
    /// 식별자
    let id: UInt64
    /// 문의 생성일시
    let createdAt: Date
    /// 문의 수정일시
    let modifiedAt: Date
    /// 문의 제목
    let title: String
    /// 문의 내용
    let content: String
    /// 문의 사진
    let images: [UIImage]
    /// 문의 답변 여부
    let isAnswered: Bool
    /// 문의 답변 내용
    let answerContent: String?
}

/// 사용자 문의 검색 기준의 종류
enum InquirySearchCriteria: Int {
    case answeredOnly = 1
    case unansweredOnly
    case all
}
