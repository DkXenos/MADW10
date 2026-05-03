//
//  User.swift
//  LabWeek10
//
//  Created by Jason TIo on 04/05/26.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    
    
    @DocumentID var id: String?
    
    var email: String
    
    var achievements: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case achievements
    }
}
