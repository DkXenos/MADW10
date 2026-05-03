//
//  StoryNode.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//
//  MARK: - StoryNode & Choice Data Models
//  StoryNode represents a single narrative node within a story.
//  Each node has a unique nodeId, narrative text, a flag indicating
//  if it's the main entry point, and an array of Choice objects.
//  Choice represents a selectable option that links to another node.
//

import Foundation

/// Represents a single node in the interactive story tree.
/// Each node contains narrative text and zero or more choices.
/// A node with no choices is considered an ending node.
struct StoryNode: Codable, Identifiable {
    
    // MARK: - Properties
    
    /// Unique identifier for this node within the story.
    /// Used by Choice.targetNodeId to create connections between nodes.
    var nodeId: String
    
    /// The narrative text displayed to the user at this point in the story.
    /// This text is revealed with a typewriter animation in the GameplayView.
    var narrative: String
    
    /// Whether this node is the starting point of the story.
    /// Only one node per story should have this set to true.
    var isMainEntryPoint: Bool
    
    /// Array of choices available to the user at this node.
    /// Empty array means this is an ending node (story conclusion).
    var choices: [Choice]
    
    // MARK: - Identifiable Conformance
    /// Use nodeId as the unique identifier for SwiftUI
    var id: String { nodeId }
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case nodeId
        case narrative
        case isMainEntryPoint
        case choices
    }
}

/// Represents a single choice/option within a StoryNode.
/// Each choice has a display label and a target node ID that
/// determines which node the story progresses to when selected.
struct Choice: Codable, Identifiable {
    
    // MARK: - Properties
    
    /// The display text for this choice button (e.g., "Meditasi Chakra")
    var label: String
    
    /// The nodeId of the StoryNode this choice leads to.
    /// Must match an existing StoryNode.nodeId within the same story.
    var targetNodeId: String
    
    // MARK: - Identifiable Conformance
    /// Generate a unique ID by combining label and target for SwiftUI lists
    var id: String { "\(label)-\(targetNodeId)" }
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case label
        case targetNodeId
    }
}
