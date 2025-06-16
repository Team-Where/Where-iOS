//
//  SharePlaceMeetingListView.swift
//  Where
//
//  Created by BOMBSGIE on 6/16/25.
//

import SwiftUI

struct SharePlaceMeetingListView: View {
    
    @State private var selectedMeeting: Meeting?
    
    private var disabled: Bool {
        selectedMeeting == nil
    }
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 120, maximum: 175))]
    
    var body: some View {
        VStack(alignment:.leading) {
            
            Text("장소를 공유할\n모임을 선택해주세요")
                .whereFont(.title24semibold)
                .padding(.bottom)
            //TODO: 실제 데이터 값 채워 넣기
            ScrollView(.vertical) {
                LazyVGrid(columns: columns) {
                    ForEach([Meeting(id: 1,
                                     title: "2024 연말파티",
                                     description: "!2",
                                     createdAt: .now,
                                     isFinished: false),
                             Meeting(id: 2,
                                     title: "2024 연말파티",
                                     description: "!2",
                                     createdAt: .now,
                                              isFinished: false)
                    ]) { meeting in
                        MeetingCell(selectedMeeting: $selectedMeeting, meeting: meeting)
                            .onTapGesture {
                                selectedMeeting = meeting
                            }
   
                    }
                }
            }
            
            Button {
                //TODO: View이동
            } label: {
                Text("완료")
                    .frame(width: 350, height: 48)
            }
            .buttonStyle(.whereRoundedProminent(disabled: disabled))
        }
        .padding(.horizontal, 20)
    }
}

extension SharePlaceMeetingListView {
    struct MeetingCell: View {
        @Binding var selectedMeeting: Meeting?
        let meeting: Meeting
        
        var body: some View {
            VStack(alignment: .leading) {
                AsyncImage(url: nil) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(.rect(cornerRadius: 10))
                } placeholder: {
                    Image(.defaultCover)
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(.rect(cornerRadius: 10))
                }
                .overlay {
                    if selectedMeeting == meeting {
                        RoundedRectangle(cornerRadius: 10)
                            .opacity(0.6)
                        Image(.whereCheckmark)
                            .background {
                                Circle()
                                    .frame(width: 32, height: 32)
                                    .foregroundStyle(.accent)
                            }
                    }
                }
                Text(meeting.title)
                    .whereFont(.body16regular)
                Text(meeting.scheduleDate?.toString() ?? "아직 정해진 일정이 없습니다.")
                    .whereFont(.body14regular)
            }
        }
    }
}

#Preview {
    SharePlaceMeetingListView()
}
