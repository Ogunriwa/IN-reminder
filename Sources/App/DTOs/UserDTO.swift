//
//  File.swift
//  IN-reminder
//
//  Created by Ibrahim Arogundade on 10/6/24.
//

import Fluent
import Vapor

struct UserDTO: Content {
    
    var id: UUID?
    var name: String?
    var email: String?
    var password: String?
    
    
    
    func toModel() -> User {
        
        let user = User()
        
        user.id = self.id
        if let name = self.name {
            user.name = name
        }
        
        if let email = self.email {
            user.email = email
        }
        
       
       
        return user
    }
    
    
    
    
}


