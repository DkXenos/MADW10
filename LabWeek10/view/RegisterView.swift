//
//  RegisterView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//

import SwiftUI
import Combine

struct RegisterView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(spacing: 24) {
            
            Spacer()
            
            Text("Register")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Buat akun untuk memulai petualanganmu")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            
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
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.caption)
                    .foregroundColor(.secondary)
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
            }
            .padding(.horizontal)
            
            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
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
