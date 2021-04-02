//
//  File.swift
//  
//
//  Created by shun on 2021/3/28.
//

import Foundation
import Fluent
import Vapor

final class Note: Model, Content {
    // 表名
    static let schema = "notes"

    // 主键
    @ID(custom: "id")
    var id: Int?

    // The Galaxy's name.
    @Field(key: "title")
    var title: String
    
    @Field(key: "content")
    var content: String?
    
//    func prepare(on database: Database) -> EventLoopFuture<Void> {
//        database.schema("notes")
//            .id()
//            .field("title", .string)
//            .field("content", .string)
//            .create()
//    }
//    func revert(on database: Database) -> EventLoopFuture<Void> {
//        database.schema("notes").delete()
//    }
    // Creates a new, empty Galaxy.
    init() { }

    // Creates a new Galaxy with all properties set.
    init(id: Int? = nil, title: String) {
        self.id = id ?? 1
        self.title = title
    }
    
//    public static func getFirstNote(req: Request) -> Note? {
//        let note = Note.query(on: req.db).first()
//        return Note.query(on: req.db).first()
//    }
}
