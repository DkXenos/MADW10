//
//  AuthViewModel.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - Authentication ViewModel
//  Handles all Firebase Authentication logic including:
//  - Sign in with email/password
//  - Register new account with email/password
//  - Sign out
//  - Listening to auth state changes
//  - Creating user document in Firestore on registration
//
//  This ViewModel is published as an @EnvironmentObject so all views
//  can reactively respond to auth state changes.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// ViewModel responsible for managing Firebase Authentication state.
/// Uses @Published properties to reactively update the UI when auth state changes.
class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Tracks whether the user is currently signed in.
    /// ContentView observes this to switch between Login and MainTab.
    @Published var isSignedIn: Bool = false
    
    /// Stores error messages from auth operations to display to the user.
    @Published var errorMessage: String = ""
    
    /// Indicates whether an auth operation is currently in progress.
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    
    /// Firestore database reference for creating user documents
    private let db = Firestore.firestore()
    
    /// Auth state listener handle, used to remove listener on deinit
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    // MARK: - Initialization
    
    /// Sets up an auth state listener that fires whenever the user's
    /// sign-in state changes (login, logout, app launch).
    init() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isSignedIn = user != nil
            }
        }
    }
    
    /// Remove the auth state listener when this ViewModel is deallocated
    deinit {
        if let handle = authStateListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Sign In
    
    /// Signs in an existing user with email and password.
    /// - Parameters:
    ///   - email: The user's email address
    ///   - password: The user's password
    /// On success, isSignedIn is automatically updated by the auth state listener.
    /// On failure, errorMessage is set with the error description.
    func signIn(email: String, password: String) {
        // Validate inputs are not empty
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email dan password tidak boleh kosong."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    // Display the Firebase error message to the user
                    self?.errorMessage = error.localizedDescription
                }
                // On success, the auth state listener will set isSignedIn = true
            }
        }
    }
    
    // MARK: - Register
    
    /// Creates a new user account with email and password.
    /// Also creates a corresponding user document in Firestore.
    /// - Parameters:
    ///   - email: The new user's email address
    ///   - password: The new user's password
    func register(email: String, password: String) {
        // Validate inputs are not empty
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email dan password tidak boleh kosong."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    // Display registration error to the user
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                // Successfully registered — create user document in Firestore
                if let uid = result?.user.uid, let email = result?.user.email {
                    self?.createUserDocument(uid: uid, email: email)
                }
                // Auth state listener will handle isSignedIn update
            }
        }
    }
    
    // MARK: - Sign Out
    
    /// Signs out the current user.
    /// On success, the auth state listener will set isSignedIn = false,
    /// which triggers ContentView to show LoginView.
    func signOut() {
        do {
            try Auth.auth().signOut()
            // Auth state listener handles the UI update
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Helper Methods
    
    /// Creates a new user document in the "users" Firestore collection.
    /// Called automatically after successful registration.
    /// - Parameters:
    ///   - uid: The Firebase Auth UID to use as the document ID
    ///   - email: The user's email to store in the document
    private func createUserDocument(uid: String, email: String) {
        let userData: [String: Any] = [
            "email": email,
            "achievements": []   // Start with empty achievements
        ]
        
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print("Error creating user document: \(error.localizedDescription)")
            }
        }
    }
}
