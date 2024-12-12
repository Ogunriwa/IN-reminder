//
//  File.swift
//  IN-reminder
//
//  Created by Ibrahim Arogundade on 10/6/24.
//

import Foundation
import Vapor
import Fluent

struct UserController: RouteCollection {
    
    
    func boot(routes: RoutesBuilder) throws {
        
        let users = routes.grouped("signin")
        users.post(use: self.create)
        
        let user_protected = routes.grouped(User.authenticator())
        user_protected.post("login",  use: self.login)
        
        let user_access = routes.grouped(UserToken.authenticator(), User.guardMiddleware())
        user_access.get("user", use: self.user)
    }
    
    // Sign Up form
    @Sendable
    func create(req: Request) async throws -> User {
        
        //Validate the log in
        try User.Create.validate(content:req)
        
         //Take the user inputted values and map them to User.Create.self
        let createUser = try req.content.decode(User.Create.self)
        
        //Confirm the password
        guard createUser.confirmPassword == createUser.password else {
            throw Abort(.badRequest, reason: "Passwords do not match")
        }
        
        let hashedPassword = try Bcrypt.hash(createUser.password)
        
        //Create the user
        let user = User(
                    name: createUser.name,
                    email: createUser.email,
                    passwordHash: hashedPassword
                )
        
        try await user.save(on:req.db)
        return user
        
    }
    
    //Login route
    @Sendable
    func login(req: Request) async throws -> UserToken {
        
       
        do {
            
            // User.self access requires authorization
            let credentials = try req.content.decode(LoginCred.self)
            
         
            
            guard let user = try await User.query(on: req.db)
                .filter(\.$email == credentials.email)
                .first() else {
                throw Abort(.notFound, reason: "User not found")
            }
            
            guard try user.verify(password:credentials.password) else {
                
                throw Abort(.unauthorized, reason: "Invalid password")
            }
            
             
            
           
            let token = try user.generateToken()
            
            //Save the token
            try await token.save(on: req.db)
            
            // return the token
            return token
            
        }
        
       
        
        catch {
            throw Abort(.unauthorized, reason: "Not authenticated")
        }
        
    }
    
    @Sendable
    func user(req: Request) async throws -> UserDTO {
        
        // get the user after authorization
        let user = try req.auth.require(User.self)
        return user.toDTO()
    }
    
    
    
    
    
}
