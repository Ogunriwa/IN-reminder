//
//  File.swift
//  IN-reminder
//
//  Created by Ibrahim Arogundade on 10/13/24.
//

import Foundation
import Vapor
import Fluent

struct LoginResponse: Content {
    
    var user: UserDTO
    var token: String
    
}
