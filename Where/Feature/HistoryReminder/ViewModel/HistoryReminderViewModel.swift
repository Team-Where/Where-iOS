//
//  HistoryReminderViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/24/25.
//

import Foundation
import Combine

@Observable
final class HistoryReminderViewModel {
    private(set) var yearGroups = [YearGroup]()
    
    private let meetingCore: MeetingCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(meetingCore: MeetingCoreProtocol) {
        self.meetingCore = meetingCore
        subscribe()
    }
    
    private func subscribe() {
        meetingCore.meetingSummaries
            .receive(on: DispatchQueue.main)
            .sink { completion in
                
            } receiveValue: { [weak self] dict in
                let calendar = Calendar.current
                var grouped = [Int: [Int: [MeetingSummary]]]()
                dict.values.forEach {
                    let year = calendar.component(.year, from: $0.finishedAt)
                    let month = calendar.component(.month, from: $0.finishedAt)
                    grouped[year, default: [:]][month, default: []].append($0)
                }
                let sortedGroups = grouped
                    .sorted(by: { $0.key > $1.key })
                    .map { (year, monthsDict) in
                        let monthGroups = monthsDict
                            .sorted(by: { $0.key > $1.key })
                            .map { (month, meetings) in
                                let sortedMeetings = meetings.sorted(by: { $0.finishedAt > $1.finishedAt })
                                return MonthGroup(year: year, month: month, meetings: sortedMeetings)
                            }
                        return YearGroup(year: year, months: monthGroups)
                    }
                
                self?.yearGroups = sortedGroups
            }
            .store(in: &cancellables)
    }
}

// MARK: - Nested Types
extension HistoryReminderViewModel {
    struct MonthGroup: Identifiable {
        let id: String
        let month: Int
        let meetings: [MeetingSummary]
        
        init(year: Int, month: Int, meetings: [MeetingSummary]) {
            self.id = "\(year)-\(month)"
            self.month = month
            self.meetings = meetings
        }
    }
    
    struct YearGroup: Identifiable {
        let year: Int
        let months: [MonthGroup]
        
        var id: Int { year }
    }
}
