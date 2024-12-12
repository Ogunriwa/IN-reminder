//
//  File.swift
//  IN-reminder
//
//  Created by Ibrahim Arogundade on 10/8/24.
//

import Foundation
import Vapor
import Fluent


// Creation of the Model
final class UserToken : Model, Content, @unchecked Sendable {
    
    static let schema = "user_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "token")
    var token: String
    
    @Parent(key: "user_id")
    var user: User
    
    init() {}
    
    // Initializes it
    init(id: UUID? = nil, token: String, userID: User.IDValue) {
        self.id = id
        self.token = token
        self.$user.id = userID
    }
    
}


// Migration for the model

extension UserToken {
    
    struct Migration: AsyncMigration {
        
        var name: String { "CreateUserToken" }
        
        func prepare(on database: Database) async throws {
            
            try await database.schema("user_tokens")
                .id()
                .field("token", .string, .required)
                .field("user_id", .uuid, .required, .references("users", "id"))
                .unique(on: "token")
                .create()
                
        }
        
        func revert(on database: Database) async throws {
            
            try await database.schema("user_tokens").delete()
        }
    }
}

extension UserToken: ModelTokenAuthenticatable {
    
    static let valueKey = \UserToken.$token
    static let userKey = \UserToken.$user
    
    var isValid: Bool {
        true
    }
}
