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
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Profile Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.black)
                        
                        Text(profileVM.userEmail)
                            .font(.title3)
                            .bold()
                        
                        Text("Pencatat takdir yang bijaksana")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // MARK: - Achievements Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Achievements")
                            .font(.headline)
                            .bold()
                            .padding(.horizontal)
                        
                        VStack {
                            if profileVM.achievements.isEmpty {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.black)
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "medal.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Belum ada pencapaian")
                                            .font(.subheadline)
                                            .bold()
                                        Text("Selesaikan cerita untuk mendapatkan.")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding()
                            } else {
                                ForEach(profileVM.achievements, id: \.self) { achievement in
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(Color.black)
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "medal.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 16))
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(achievement)
                                                .font(.subheadline)
                                                .bold()
                                            Text("Satu cerita selesai.")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Seed Data Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Seed Data")
                            .font(.headline)
                            .bold()
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            // Row 1: Bajak Laut
                            Button(action: { profileVM.seedBajakLaut() }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Bajak laut")
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(.primary)
                                        Text("Mulai petualangan mencari harta karun samudra.")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "plus")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                            
                            Divider().padding(.horizontal)
                            
                            // Row 2: Ninja
                            Button(action: { profileVM.seedNinja() }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Ninja")
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(.primary)
                                        Text("Mulai perjalanan ninja menembus batas desa.")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "plus")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                            
                            Divider().padding(.horizontal)
                            
                            // Row 3: Romance
                            Button(action: { profileVM.seedRomance() }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Romance")
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(.primary)
                                        Text("Mulai kisah asmara manis di bawah sakura.")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "plus")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        if !profileVM.seedMessage.isEmpty {
                            Text(profileVM.seedMessage)
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.horizontal)
                        }
                    }
                    
                    // MARK: - Logout Button
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Text("Keluar Akun")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarHidden(true)
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
