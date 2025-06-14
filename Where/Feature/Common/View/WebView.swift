//
//  WebView.swift
//  Where
//
//  Created by BOMBSGIE on 6/11/25.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    private let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}
