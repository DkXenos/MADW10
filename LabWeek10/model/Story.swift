//
//  Story.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - Story Data Model
//  Represents a story document stored in the "stories" Firestore collection.
//  Each story has a title, description, and an array of StoryNode objects
//  that form the interactive narrative tree.
//  Conforms to Codable for Firestore serialization and Identifiable for SwiftUI.
//

import Foundation
import FirebaseFirestore

/// Story model representing a document in the "stories" Firestore collection.
/// Contains metadata (title, description) and the full node tree for the narrative.
struct Story: Codable, Identifiable {
    
    // MARK: - Properties
    
    /// Firestore document ID, automatically mapped by @DocumentID
    @DocumentID var id: String?
    
    /// The title of the story (e.g., "Jalan Ninja")
    var title: String
    
    /// A brief description/summary of the story
    var description: String
    
    /// Array of StoryNode objects that make up the interactive narrative
    /// Each node contains text, choices, and connection info
    var nodes: [StoryNode]
    
    // MARK: - Coding Keys
    /// Maps Swift property names to Firestore field names
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case nodes
    }
}
