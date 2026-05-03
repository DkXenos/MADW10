//
//  User.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - User Data Model
//  Represents a user document stored in the "users" Firestore collection.
//  Tracks the user's email and their achievements (completed story IDs).
//  Conforms to Codable for seamless Firestore serialization/deserialization.
//  Conforms to Identifiable for use in SwiftUI Lists.
//

import Foundation
import FirebaseFirestore

/// User model representing a document in the "users" Firestore collection.
/// Each user has an email and a list of achievement strings (completed story titles).
struct User: Codable, Identifiable {
    
    // MARK: - Properties
    
    /// Firestore document ID, automatically mapped by @DocumentID
    @DocumentID var id: String?
    
    /// The user's email address (from FirebaseAuth)
    var email: String
    
    /// List of completed story titles/IDs representing the user's achievements
    var achievements: [String]
    
    // MARK: - Coding Keys
    /// Maps Swift property names to Firestore field names
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case achievements
    }
}
