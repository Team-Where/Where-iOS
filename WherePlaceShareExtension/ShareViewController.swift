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
    private var placeName: String?
    private var placeURLString: String?
    
    override func isContentValid() -> Bool {
        guard let name = placeName, name.isEmpty == false,
              let urlString = placeURLString, urlString.isEmpty == false,
              URL(string: urlString) != nil
        else { return false }
        return true
    }

    override func didSelectPost() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem],
              let item = extensionItems.first,
              let attachments = item.attachments, attachments.isEmpty == false
        else { return completeRequest() }
        
        guard let textProvider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.text.identifier) }) else {
            return completeRequest()
        }
        
        textProvider.loadItem(forTypeIdentifier: UTType.text.identifier) { [weak self] data, error in
            guard error == nil, let text = data as? String else {
                self?.completeRequest()
                return
            }
            
            if text.contains("[네이버 지도]") {
                let lines = text.components(separatedBy: .newlines)
                guard lines.count >= 3 else {
                    self?.completeRequest()
                    return
                }
                self?.placeName = lines[1].trimmingCharacters(in: .whitespaces)
                self?.placeURLString = lines[2].trimmingCharacters(in: .whitespaces)
                self?.completeRequest()
            } else if text.contains("[카카오맵]") {
                self?.placeName = text.replacingOccurrences(of: "[카카오맵] ", with: "").trimmingCharacters(in: .whitespaces)
                guard let urlProvider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) else {
                    self?.completeRequest()
                    return
                }
                
                urlProvider.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] data, error in
                    guard error == nil, let url = data as? URL else {
                        self?.completeRequest()
                        return
                    }
                    self?.placeURLString = url.absoluteString
                    self?.completeRequest()
                }
            } else {
                self?.completeRequest()
            }
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    private func deeplink(name: String, stringLink: String) -> URL? {
        var component = URLComponents()
        component.scheme = "audiwhere"
        component.host = "share"
        component.queryItems = [
            URLQueryItem(name: "name", value: name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
            URLQueryItem(name: "link", value: stringLink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        ]
        return component.url
    }
    
    private func openURL(_ url: URL) {
        extensionContext?.open(url)
    }
    
    private func completeRequest() {
        defer { extensionContext?.completeRequest(returningItems: []) }
        
        guard isContentValid(),
              let name = placeName,
              let link = placeURLString,
              let deeplinkURL = deeplink(name: name, stringLink: link)
        else { return }
        openURL(deeplinkURL)
    }
}
