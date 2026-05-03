//
//  Story.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//

import Foundation
import FirebaseFirestore

struct Story: Codable, Identifiable {
    
    
    @DocumentID var id: String?
    
    var title: String
    
    var description: String
    
    var nodes: [StoryNode]
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case nodes
    }
}
