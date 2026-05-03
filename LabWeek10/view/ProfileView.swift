//
//  ProfileView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - Profile View
//  Displays user email, achievements, seed data buttons, and logout.
//

import SwiftUI

/// Profile page showing user info, achievements, seed data, and logout.
struct ProfileView: View {
    
    // MARK: - Environment
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // MARK: - State
    @StateObject private var profileVM = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - User Info Section
                Section(header: Text("Akun")) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title)
                            .foregroundColor(.secondary)
                        VStack(alignment: .leading) {
                            Text("Email")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(profileVM.userEmail)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                // MARK: - Achievements Section
                Section(header: Text("Achievements")) {
                    if profileVM.achievements.isEmpty {
                        Text("Belum ada pencapaian. Selesaikan cerita!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(profileVM.achievements, id: \.self) { achievement in
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.yellow)
                                Text(achievement)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                // MARK: - Seed Data Section
                Section(header: Text("Seed Data")) {
                    // Bajak Laut seed button
                    Button(action: {
                        profileVM.seedBajakLaut()
                    }) {
                        HStack {
                            Image(systemName: "sailboat.fill")
                            Text("Bajak Laut")
                            Spacer()
                            if profileVM.isLoading {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(profileVM.isLoading)
                    
                    // Ninja seed button
                    Button(action: {
                        profileVM.seedNinja()
                    }) {
                        HStack {
                            Image(systemName: "figure.martial.arts")
                            Text("Ninja")
                            Spacer()
                        }
                    }
                    .disabled(profileVM.isLoading)
                    
                    // Romance seed button
                    Button(action: {
                        profileVM.seedRomance()
                    }) {
                        HStack {
                            Image(systemName: "heart.fill")
                            Text("Romance")
                            Spacer()
                        }
                    }
                    .disabled(profileVM.isLoading)
                    
                    // Seed status message
                    if !profileVM.seedMessage.isEmpty {
                        Text(profileVM.seedMessage)
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                // MARK: - Logout Section
                Section {
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        HStack {
                            Spacer()
                            Text("Keluar Akun")
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                profileVM.fetchProfile()
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
