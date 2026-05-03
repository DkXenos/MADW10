//
//  MainTabView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - Main Tab View
//  Bottom tab bar with 3 tabs: Home (book), Admin (hammer), Profile (person).
//

import SwiftUI

/// Main navigation hub with a bottom tab bar.
struct MainTabView: View {
    
    // MARK: - Environment
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            // MARK: - Home Tab (Buku icon)
            HomeView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Home")
                }
            
            // MARK: - Admin Tab (Palu icon)
            AdminView()
                .tabItem {
                    Image(systemName: "hammer.fill")
                    Text("Admin")
                }
            
            // MARK: - Profile Tab (Orang icon)
            ProfileView()
                .environmentObject(authViewModel)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
