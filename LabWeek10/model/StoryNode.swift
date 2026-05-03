//
//  StoryNode.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//

import Foundation

struct StoryNode: Codable, Identifiable {
    
    
    var nodeId: String
    
    var narrative: String
    
    var isMainEntryPoint: Bool
    
    var choices: [Choice]
    
    var id: String { nodeId }
    
    enum CodingKeys: String, CodingKey {
        case nodeId
        case narrative
        case isMainEntryPoint
        case choices
    }
}

struct Choice: Codable, Identifiable {
    
    
    var label: String
    
    var targetNodeId: String
    
    var id: String { "\(label)-\(targetNodeId)" }
    
    enum CodingKeys: String, CodingKey {
        case label
        case targetNodeId
    }
}
