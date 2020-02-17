//
//  SessionResponse.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

struct sessionResponse : Codable {
    let success : Bool
    let session_id : String
    
    enum codingKeys : String , CodingKey{
        case success
        case sessionID = "session_id"
    }
}
