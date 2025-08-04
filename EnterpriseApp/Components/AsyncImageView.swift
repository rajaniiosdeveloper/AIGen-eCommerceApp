//
//  AsyncImageView.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import SwiftUI

struct AsyncImageView: View {
    let url: String
    let width: CGFloat?
    let height: CGFloat?
    let contentMode: ContentMode
    
    init(url: String, width: CGFloat? = nil, height: CGFloat? = nil, contentMode: ContentMode = .fit) {
        self.url = url
        self.width = width
        self.height = height
        self.contentMode = contentMode
    }
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } placeholder: {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                        .font(.title2)
                )
        }
        .frame(width: width, height: height)
        .clipped()
    }
}