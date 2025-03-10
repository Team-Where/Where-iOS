//
//  CalendarView.swift
//  Where
//
//  Created by Swain Yun on 1/5/25.
//

import SwiftUI

struct CalendarView: View {
    @State private var months: [Month] = [
        Date().previousMonth(),
        Date().month(),
        Date().nextMonth()
    ]
    @State private var currentIndex: Int = 1 // (0, 1, 2) -> (전월, 당월, 차월)
    @Binding var selectedDate: Date?
    
    private let daysOfWeek: [DayOfWeek] = DayOfWeek.allCases
    private let columns = [GridItem](repeating: .init(), count: DayOfWeek.count)
    
    private var currentMonth: Month { months[currentIndex] }
    
    var body: some View {
        VStack(spacing: 0) {
            calendarHeader()
            
            calendarBody()
        }
    }
    
    @ViewBuilder private func calendarHeader() -> some View {
        HStack(spacing: 12) {
            AsyncDateView(date: currentMonth.startDate, format: .yyyyMMKorean, prompt: "선택해주세요.")
                .whereFont(.title20semibold)
                .foregroundStyle(Color(hex: 0x1F2937))
            
            Spacer()
            
            HStack(spacing: 8) {
                Button {
                    withAnimation {
                        currentIndex = 0
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .padding(.horizontal, (32 - 5.33) / 2)
                        .padding(.vertical, (32 - 10.67) / 2)
                        .foregroundStyle(Color(hex: 0x1F2937))
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white)
                                .strokeBorder(Color(hex: 0xE5E7EB))
                        )
                }
                
                Button {
                    withAnimation {
                        currentIndex = 2
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .padding(.horizontal, (32 - 5.33) / 2)
                        .padding(.vertical, (32 - 10.67) / 2)
                        .foregroundStyle(Color(hex: 0x1F2937))
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white)
                                .strokeBorder(Color(hex: 0xE5E7EB))
                        )
                }
            }
        }
        .frame(height: 32)
        .padding([.top, .horizontal])
        
        HStack {
            ForEach(daysOfWeek, id: \.self) { dayOfWeek in
                Text(dayOfWeek.inShortKorean)
                    .whereFont(.caption12regular)
                    .foregroundStyle(Color(hex: 0x6B7280))
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 32)
        .padding(.top)
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder private func calendarBody() -> some View {
        TabView(selection: $currentIndex) {
            ForEach(months.indices, id: \.self) { index in
                calendarGrid(months[index])
                    .tag(index)
                    .onDisappear {
                        prepare()
                    }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder private func calendarGrid(_ month: Month) -> some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(month.days, id: \.id) { day in
                gridCell(day)
            }
        }
    }
    
    @ViewBuilder private func gridCell(_ day: Day) -> some View {
        let inSameDay = selectedDate?.inSameDay(as: day.date) ?? false
        
        Button {
            if day.isValid {
                selectedDate = inSameDay ? nil : day.date
            }
        } label: {
            Text("\(day.day)")
                .whereFont(.body16regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .foregroundStyle(inSameDay ? .white : (day.isValid ? .black : .gray))
                .background(
                    Circle()
                        .fill(inSameDay ? .black : .clear)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func prepare() {
        switch currentIndex {
        case 0:
            months[2] = months[1]
            months[1] = months[0]
            months[0] = months[0].startDate.previousMonth()
            currentIndex = 1
        case 2:
            months[0] = months[1]
            months[1] = months[2]
            months[2] = months[2].startDate.nextMonth()
            currentIndex = 1
        default:
            break
        }
    }
}

#Preview {
    MeetingInformationView()
}
