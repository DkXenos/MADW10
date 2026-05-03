//
//  ProfileView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//

import SwiftUI
import Combine

struct ProfileView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @StateObject private var profileVM = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            List {
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
                
                Section(header: Text("Seed Data")) {
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
                    
                    if !profileVM.seedMessage.isEmpty {
                        Text(profileVM.seedMessage)
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
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
