//
//  CategorySelectorView.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import SwiftUI

// MARK: - Category Selector View
struct CategorySelectorView: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    let onCategorySelected: (Category?) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // "All" category button
                CategoryButton(
                    title: "All",
                    imageURL: nil,
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                    onCategorySelected(nil)
                }
                
                // Category buttons
                ForEach(categories) { category in
                    CategoryButton(
                        title: category.name,
                        imageURL: category.imageURL,
                        isSelected: selectedCategory?.id == category.id
                    ) {
                        selectedCategory = category
                        onCategorySelected(category)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let title: String
    let imageURL: String?
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Category Image
                if let imageURL = imageURL {
                    AsyncImageView(
                        url: imageURL,
                        width: 50,
                        height: 50,
                        contentMode: .fill
                    )
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
                } else {
                    Image(systemName: "square.grid.2x2")
                        .font(.title2)
                        .foregroundColor(isSelected ? .blue : .gray)
                        .frame(width: 50, height: 50)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                        )
                }
                
                // Category Name
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .blue : .primary)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 70)
    }
}

// MARK: - Preview
struct CategorySelectorView_Previews: PreviewProvider {
    static var previews: some View {
        CategorySelectorView(
            categories: [
                Category(name: "Electronics", imageURL: "https://images.unsplash.com/photo-1498049794561-7780e7231661?w=500"),
                Category(name: "Fashion", imageURL: "https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=500"),
                Category(name: "Home", imageURL: "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=500"),
                Category(name: "Sports", imageURL: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500"),
                Category(name: "Books", imageURL: "https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=500")
            ],
            selectedCategory: .constant(nil),
            onCategorySelected: { _ in }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}