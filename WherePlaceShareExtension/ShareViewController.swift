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
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem],
              let item = extensionItems.first,
              let provider = item.attachments?.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.text.identifier) })
        else { return completeRequest() }
        
        provider.loadItem(forTypeIdentifier: UTType.text.identifier) { [weak self] data, error in
            guard error == nil, let text = data as? String else {
                self?.completeRequest()
                return
            }
            
            print("지도앱에서 꺼내온 문자열: \(text)")
            
            if let url = self?.deeplink(name: "파싱한 이름", address: "파싱한 주소") {
                self?.openURL(url)
            }
            
            self?.completeRequest()
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    private func deeplink(name: String, address: String) -> URL? {
        var component = URLComponents()
        component.scheme = "audiwhere"
        component.host = "share"
        component.queryItems = [
            URLQueryItem(name: "name", value: name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
            URLQueryItem(name: "address", value: address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        ]
        return component.url
    }
    
    private func openURL(_ url: URL) {
        extensionContext?.open(url)
    }
    
    private func completeRequest() {
        extensionContext?.completeRequest(returningItems: [])
    }
}
