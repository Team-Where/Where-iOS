//
//  ShareViewController.swift
//  WherePlaceShareExtension
//
//  Created by Swain Yun on 5/19/25.
//

import UIKit
import Social
import UniformTypeIdentifiers

final class ShareViewController: SLComposeServiceViewController {
    enum SourceAppType {
        case kakaomap, navermap
    }
    
    private var placeName: String?
    private var placeAddress: String?
    private var placeURLString: String?
    private var sourceAppType: SourceAppType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    override func isContentValid() -> Bool {
        guard let name = placeName, name.isEmpty == false else { return false }
        
        switch sourceAppType {
        case .kakaomap:
            guard let urlString = placeURLString, URL(string: urlString) != nil else { return false }
            return true
        case .navermap:
            guard let address = placeAddress, address.isEmpty == false else { return false }
            return true
        case .none:
            return false
        }
    }

    override func didSelectPost() {
        completeRequest()
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    private func loadItems() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem],
              let item = extensionItems.first,
              let attachments = item.attachments, attachments.isEmpty == false
        else { return }
        
        guard let textProvider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.text.identifier) }) else { return }
        
        textProvider.loadItem(forTypeIdentifier: UTType.text.identifier) { [weak self] data, error in
            guard error == nil, let text = data as? String else { return }
            
            if text.contains("[네이버 지도]") {
                self?.sourceAppType = .navermap
                let lines = text.components(separatedBy: .newlines)
                guard lines.count >= 3 else { return }
                self?.placeName = lines[1].trimmingCharacters(in: .whitespaces)
                self?.placeAddress = lines[2].trimmingCharacters(in: .whitespaces)
                self?.validateContent()
            } else if text.contains("[카카오맵]") {
                self?.sourceAppType = .kakaomap
                self?.placeName = text.replacingOccurrences(of: "[카카오맵] ", with: "").trimmingCharacters(in: .whitespaces)
                guard let urlProvider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) else { return }
                
                urlProvider.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] data, error in
                    guard error == nil, let url = data as? URL else { return }
                    self?.placeURLString = url.absoluteString
                    self?.validateContent()
                }
            }
        }
    }
    
    private func deeplink(sourceApp: SourceAppType, name: String, address: String? = nil, link: String? = nil) -> URL? {
        var component = URLComponents()
        component.scheme = "audiwhere"
        component.host = "share"
        component.queryItems = [
            URLQueryItem(name: "name", value: name),
        ]
        
        switch sourceApp {
        case .kakaomap:
            guard let link else { return nil }
            component.queryItems?.append(.init(name: "link", value: link))
        case .navermap:
            guard let address else { return nil }
            component.queryItems?.append(.init(name: "address", value: address))
        }
        return component.url
    }
    
    private func openURL(_ url: URL) {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url)
                break
            }
            responder = responder?.next
        }
    }
    
    private func completeRequest() {
        defer { extensionContext?.completeRequest(returningItems: []) }
        
        guard isContentValid(),
              let name = placeName,
              let source = sourceAppType,
              let deeplinkURL = deeplink(sourceApp: source, name: name, address: placeAddress, link: placeURLString)
        else { return }
        print("파싱한 장소명: \(name)")
        print("공유받은 앱: \(source)")
        print("딥링크: \(deeplinkURL)")
        openURL(deeplinkURL)
    }
}
