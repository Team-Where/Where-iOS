//
//  PlaceInfo.swift
//  Where
//
//  Created by 이현호 on 1/20/25.
//

import SwiftUI

struct PlaceInfo: View {
    var imageName: String
    var name: String
    var address: String
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 220, height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Text(name)
                .whereFont(.title24semibold)
                .padding(.top, 16)
            
            Text(address)
                .whereFont(.body16regular)
                .padding(.top, 4)
        }
    }
}
