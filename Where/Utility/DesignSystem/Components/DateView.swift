//
//  DateView.swift
//  Where
//
//  Created by Swain Yun on 5/2/25.
//

import SwiftUI

struct DateView: View {
    @State private var time: String = String()
    @Binding var date: Date?
    
    private let format: DateFormat
    private let prompt: String
    
    init(
        date: Binding<Date?>,
        format: DateFormat,
        prompt: String
    ) {
        self._date = date
        self.format = format
        self.prompt = prompt
    }
    
    init(
        date: Date?,
        format: DateFormat,
        prompt: String
    ) {
        self.init(date: .constant(date), format: format, prompt: prompt)
    }
    
    var body: some View {
        Text(time)
            .onChange(of: date) { _, newValue in
                guard let newValue else {
                    return time = prompt
                }
                
                time = newValue.toString(by: format)
            }
            .onAppear {
                guard let date else {
                    return time = prompt
                }
                
                time = date.toString(by: format)
            }
    }
}
