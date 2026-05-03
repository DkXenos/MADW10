//
//  LabWeek10App.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//

import SwiftUI
import Combine
import FirebaseCore

@main
struct LabWeek10App: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
