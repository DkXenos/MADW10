//
//  LabWeek10App.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - App Entry Point
//  This is the main entry point for the Interactive Story application.
//  Firebase is initialized here using FirebaseApp.configure() inside init().
//  The root view is ContentView which handles auth-based routing.
//

import SwiftUI
import FirebaseCore

@main
struct LabWeek10App: App {
    
    // MARK: - Firebase Initialization
    /// Initialize Firebase when the app launches.
    /// This must be called before any Firebase services are used.
    init() {
        FirebaseApp.configure()
    }
    
    // MARK: - State Objects
    /// AuthViewModel is created here as a @StateObject and injected
    /// into the environment so all child views can access it.
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            // ContentView acts as the root router based on auth state
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
