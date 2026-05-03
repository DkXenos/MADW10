//
//  ContentView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - Root Router View
//  This view serves as the authentication router for the app.
//  It checks if a user is currently signed in and routes accordingly:
//  - If signed in -> MainTabView (the main app experience)
//  - If not signed in -> LoginView (authentication flow)
//

import SwiftUI
import Combine

struct ContentView: View {
    
    // MARK: - Environment
    /// Access the shared AuthViewModel to determine login state
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            // Check if the user is currently authenticated
            if authViewModel.isSignedIn {
                // User is logged in, show the main app with tab navigation
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                // User is not logged in, show the login screen
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
        // Animate the transition between auth states
        .animation(.easeInOut, value: authViewModel.isSignedIn)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
