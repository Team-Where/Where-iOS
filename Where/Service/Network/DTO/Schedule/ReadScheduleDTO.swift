//
//  ReadScheduleDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

/// 일정 조회
enum ReadScheduleDTO {    
    struct Response: Decodable {
        let date: String
        let time: String
    }
}
