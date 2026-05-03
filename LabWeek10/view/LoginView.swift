//
//  LoginView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - Login View
//  Presents email and password fields for user authentication.
//  Includes navigation to RegisterView for new users.
//

import SwiftUI

/// Login screen with email/password fields and navigation to register.
struct LoginView: View {
    
    // MARK: - Environment
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // MARK: - State
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showRegister: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                Spacer()
                
                // MARK: - App Icon
                Image(systemName: "target")
                    .font(.system(size: 48))
                    .foregroundColor(.primary)
                
                // MARK: - Title
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // MARK: - Subtitle
                Text("Ceritamu sudah menunggumu di sini")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                
                // MARK: - Email Field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                }
                .padding(.horizontal)
                
                // MARK: - Password Field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Password")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                }
                .padding(.horizontal)
                
                // MARK: - Error Message
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // MARK: - Login Button
                Button(action: {
                    authViewModel.signIn(email: email, password: password)
                }) {
                    HStack {
                        if authViewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("Login")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary)
                    .foregroundColor(Color(.systemBackground))
                    .cornerRadius(12)
                }
                .disabled(authViewModel.isLoading)
                .padding(.horizontal)
                
                // MARK: - Register Navigation
                Button(action: {
                    showRegister = true
                }) {
                    Text("Register New Account")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
