//
//  File.swift
//  
//
//  Created by shun on 2021/4/9.
//

import Fluent
import Vapor
import FluentMySQLDriver
/// 用户令牌
final class UserToken: Model, Content {
    static let schema = "user_tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "value")
    var value: String

    @Parent(key: "user_id")
    var user: User

    init() { }

    init(id: UUID? = nil, value: String, userID: User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}
extension UserToken {
    struct Migration: Fluent.Migration {
        var name: String { "CreateUserToken" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("user_tokens")
                .id()
                .field("value", .string, .required)
                .field("user_id", .uuid, .required, .references("users", "id"))
                .unique(on: "value")
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("user_tokens").delete()
        }
    }
}
extension UserToken: ModelTokenAuthenticatable {
    static let valueKey = \UserToken.$value
    static let userKey = \UserToken.$user

    var isValid: Bool {
        true
    }
}


final class User: Model, Content {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "password_hash")
    var passwordHash: String

    init() { }

    init(id: UUID? = nil, name: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.passwordHash = passwordHash
    }
}

extension User {
    struct Create: Content {
        var name: String
        var password: String
        var confirmPassword: String
    }
}
extension User.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension User {
    struct User_20210409_1_Migration: Fluent.Migration {
        var name: String { "CreateUser" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("users")
                .id()
                .field("name", .string, .required)
                .field("password_hash", .string, .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("users").delete()
        }
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$name
    static let passwordHashKey = \User.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

extension User {
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}
