//
//  AuthViewModel.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    
    
    @Published var isSignedIn: Bool = false
    
    @Published var errorMessage: String = ""
    
    @Published var isLoading: Bool = false
    
    
    private let db = Firestore.firestore()
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    
    init() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isSignedIn = user != nil
            }
        }
    }
    
    deinit {
        if let handle = authStateListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    
    func signIn(email: String, password: String) {
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
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    
    func register(email: String, password: String) {
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
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                if let uid = result?.user.uid, let email = result?.user.email {
                    self?.createUserDocument(uid: uid, email: email)
                }
            }
        }
    }
    
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    
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
