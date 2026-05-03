//
//  ContentView.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isSignedIn {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
        .animation(.easeInOut, value: authViewModel.isSignedIn)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
