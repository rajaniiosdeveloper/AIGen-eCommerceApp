//
//  MenuView.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import SwiftUI

// MARK: - Menu View
struct MenuView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    
    let onOrderHistoryTap: () -> Void
    let onSignOutTap: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    VStack(spacing: 16) {
                        // Profile Section
                        VStack(spacing: 12) {
                            // Profile Picture Placeholder
                            Circle()
                                .fill(Color.blue.gradient)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text(userInitials)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                            
                            // User Info
                            VStack(spacing: 4) {
                                Text(authManager.currentUser?.name ?? "Guest User")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text(authManager.currentUser?.email ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGroupedBackground))
                    
                    // Menu Options
                    VStack(spacing: 0) {
                        // Order History
                        MenuRowView(
                            icon: "clock.arrow.circlepath",
                            title: "Order History",
                            subtitle: "View your past orders"
                        ) {
                            onOrderHistoryTap()
                        }
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        // Account & Settings
                        MenuRowView(
                            icon: "person.circle",
                            title: "Account & Settings",
                            subtitle: "Manage your account"
                        ) {
                            // TODO: Implement account settings
                        }
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        // Help & Support
                        MenuRowView(
                            icon: "questionmark.circle",
                            title: "Help & Support",
                            subtitle: "Get help and support"
                        ) {
                            // TODO: Implement help & support
                        }
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        // About
                        MenuRowView(
                            icon: "info.circle",
                            title: "About",
                            subtitle: "App version and information"
                        ) {
                            // TODO: Implement about page
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    
                    // Sign Out Button
                    VStack(spacing: 0) {
                        Divider()
                            .padding(.leading, 60)
                        
                        MenuRowView(
                            icon: "arrow.right.square",
                            title: "Sign Out",
                            subtitle: "",
                            isDestructive: true
                        ) {
                            onSignOutTap()
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    Spacer()
                }
            }
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Will be handled by the parent view dismissing the sheet
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    private var userInitials: String {
        guard let name = authManager.currentUser?.name else { return "G" }
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
}

// MARK: - Menu Row View
struct MenuRowView: View {
    let icon: String
    let title: String
    let subtitle: String
    let isDestructive: Bool
    let onTap: () -> Void
    
    init(icon: String, title: String, subtitle: String, isDestructive: Bool = false, onTap: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.isDestructive = isDestructive
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isDestructive ? .red : .blue)
                    .frame(width: 28, height: 28)
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isDestructive ? .red : .primary)
                        .multilineTextAlignment(.leading)
                    
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                // Chevron
                if !isDestructive {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(
            onOrderHistoryTap: {},
            onSignOutTap: {}
        )
    }
}