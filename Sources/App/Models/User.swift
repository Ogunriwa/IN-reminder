//
//  File.swift
//  IN-reminder
//
//  Created by Ibrahim Arogundade on 10/5/24.
//



import Fluent
import Vapor



final class User: Model, Content, @unchecked Sendable {
    
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var passwordHash: String
    
    init() { }
    
    init(id: UUID? = nil, name: String, email: String, passwordHash: String ) {

        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        
    }
    
    
    
}


extension User {
    
    struct Migration: AsyncMigration {
        
        var name: String {"CreateUser"}
        
        func prepare(on database: Database) async throws {
            try await database.schema("users")
                .id()
                .field("name", .string, .required)
                .field("email", .string, .required)
                .field("password_hash", .string, .required)
                .unique(on: "email")
                .create()
        }
        
        func revert(on database: Database) async throws {
            try await database.schema("users").delete()
        }
    }
}


extension User {
    
    struct Create: Content {
        var name: String
        var email: String
        var password: String
        var confirmPassword: String
    }
}


extension User.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count((8...)))
    }
}


extension User: ModelAuthenticatable {
    
    
    
    static let usernameKey: KeyPath<User, Field<String>> = \User.$email
    static let passwordHashKey: KeyPath<User, Field<String>> = \User.$passwordHash
    
    
    func verify(password: String) throws -> Bool {
        
        try Bcrypt.verify(password, created: self.passwordHash)
        
    }
    
    
}

extension User {
    
    func generateToken() throws -> UserToken {
        
        try .init(
            token: [UInt8].random(count:16).base64,
            userID: self.requireID()
        )
    }
}
    
extension User {
    
    func toDTO() -> UserDTO {
        .init(
            id: self.id,
            name: self.name,
            email: self.email
        )
    }
}


