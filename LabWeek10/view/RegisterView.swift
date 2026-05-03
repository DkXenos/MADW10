//
//  RegisterView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - Register View
//  Allows new users to create an account with email and password.
//  On success, navigates back (auth state listener handles routing).
//

import SwiftUI

/// Registration screen with email/password fields.
struct RegisterView: View {
    
    // MARK: - Environment
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    // MARK: - State
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(spacing: 24) {
            
            Spacer()
            
            // MARK: - Title
            Text("Register")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // MARK: - Subtitle
            Text("Buat akun untuk memulai petualanganmu")
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
                    .textContentType(.newPassword)
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
            
            // MARK: - Register Button
            Button(action: {
                authViewModel.register(email: email, password: password)
            }) {
                HStack {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("Register")
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
            
            // MARK: - Back to Login
            Button(action: {
                dismiss()
            }) {
                Text("Back to Login")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthViewModel())
}
