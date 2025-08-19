//
//  ErrorToastView.swift
//  EnterpriseApp
//
//  Created by AI Assistant - Error Handling Component
//

import SwiftUI

// MARK: - Error Toast View
struct ErrorToastView: View {
    let error: NetworkError
    let onRetry: (() -> Void)?
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Network Error")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                if let onRetry = onRetry {
                    Button("Retry") {
                        onRetry()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                
                Button("Dismiss") {
                    onDismiss()
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Error Toast Modifier
struct ErrorToastModifier: ViewModifier {
    let error: NetworkError?
    let onRetry: (() -> Void)?
    let onDismiss: () -> Void
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let error = error, isVisible {
                    ErrorToastView(
                        error: error,
                        onRetry: onRetry,
                        onDismiss: onDismiss
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .zIndex(1000)
                }
            }
            .onChange(of: error) { _, newError in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    isVisible = newError != nil
                }
                
                // Auto-dismiss after 5 seconds
                if newError != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        if error != nil {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                onDismiss()
                            }
                        }
                    }
                }
            }
    }
}

// MARK: - View Extension
extension View {
    func errorToast(
        error: NetworkError?,
        onRetry: (() -> Void)? = nil,
        onDismiss: @escaping () -> Void
    ) -> some View {
        self.modifier(ErrorToastModifier(
            error: error,
            onRetry: onRetry,
            onDismiss: onDismiss
        ))
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Text("Sample Content")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .errorToast(
        error: NetworkError.networkFailure("Sample network error for preview"),
        onRetry: {},
        onDismiss: {}
    )
}