//
//  Logout.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

struct LogoutRequest : Codable {
    let session_id : String
    
    enum codingkeys : String , CodingKey{
        case session_id = "sessionID"
    }
    
    
}

