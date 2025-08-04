//
//  SignInView.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import SwiftUI
import Combine

// MARK: - Sign In View
struct SignInView: View {
    @StateObject private var presenter = SignInPresenter()
    @StateObject private var authManager = AuthenticationManager.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isRegisterMode = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let onSignInSuccess: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 40)
                    
                    // App Logo/Title
                    VStack(spacing: 12) {
                        Image(systemName: "cart.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("Welcome!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(isRegisterMode ? "Create your account" : "Sign in to continue")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 20)
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        if isRegisterMode {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Full Name")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("Enter your name", text: $name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.words)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            SecureField("Enter your password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        // Primary Action Button
                        Button(action: {
                            Task {
                                await handlePrimaryAction()
                            }
                        }) {
                            HStack {
                                if presenter.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text(isRegisterMode ? "Register" : "Sign In")
                                        .fontWeight(.semibold)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .disabled(presenter.isLoading || !isFormValid)
                        .opacity(presenter.isLoading || !isFormValid ? 0.6 : 1.0)
                        
                        // Secondary Action Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isRegisterMode.toggle()
                                clearForm()
                            }
                        }) {
                            Text(isRegisterMode ? "Already have an account? Sign In" : "Don't have an account? Register")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .disabled(presenter.isLoading)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onChange(of: presenter.errorMessage) { _, errorMessage in
            if let error = errorMessage {
                alertMessage = error
                showingAlert = true
            }
        }
        .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                onSignInSuccess()
            }
        }
    }
    
    // MARK: - Helper Properties
    private var isFormValid: Bool {
        if isRegisterMode {
            return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                   email.contains("@") &&
                   password.count >= 6
        } else {
            return email.contains("@") && password.count >= 6
        }
    }
    
    // MARK: - Helper Methods
    private func handlePrimaryAction() async {
        if isRegisterMode {
            await presenter.register(name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                   email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                                   password: password)
        } else {
            await presenter.signIn(email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                                 password: password)
        }
    }
    
    private func clearForm() {
        email = ""
        password = ""
        name = ""
    }
}

// MARK: - Sign In Presenter (VIPER)
@MainActor
class SignInPresenter: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let interactor: SignInInteractorProtocol
    
    init(interactor: SignInInteractorProtocol = SignInInteractor()) {
        self.interactor = interactor
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await interactor.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func register(name: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await interactor.register(name: name, email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - Preview
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView {
            print("Sign in successful")
        }
    }
}