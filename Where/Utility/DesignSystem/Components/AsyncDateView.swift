//
//  AsyncDateView.swift
//  Where
//
//  Created by Swain Yun on 1/4/25.
//

import SwiftUI

struct AsyncDateView: View {
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
                Task { @MainActor in
                    guard let newValue = newValue else {
                        time = prompt
                        return
                    }
                    time = await newValue.toString(by: format)
                }
            }
            .task {
                guard let date = date else {
                    time = prompt
                    return
                }
                time = await date.toString(by: format)
            }
    }
}
