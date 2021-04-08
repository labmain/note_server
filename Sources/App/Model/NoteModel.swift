//
//  File.swift
//  
//
//  Created by shun on 2021/3/28.
//

import Foundation
import Fluent
import FluentMySQLDriver
import Vapor

let t_note_table_content: FieldKey = "content"
let t_note_table_user_id: FieldKey = "user_id"
let t_note_table_note_book_id: FieldKey = "note_book_id"
let t_note_table_create_time: FieldKey = "create_time"
let t_note_table_update_time: FieldKey = "update_time"
let t_note_table_deleted_at: FieldKey = "deleted_at"

struct Note_20210408_1_Migration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        // , .required, .custom("DEFAULT 'current'")
        database.schema("notes")
            .id()
            .field(t_note_table_content, .string)
            .field(t_note_table_user_id, .string)
            .field(t_note_table_note_book_id, .string)
            .field(t_note_table_create_time, .double)
            .field(t_note_table_update_time, .double)
            .field(t_note_table_deleted_at, .double)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("notes").delete()
    }
}

final class Note: Model, Content {
    // 表名
    static let schema = "notes"

    // 主键
    @ID(key: .id)
    var id: UUID?

    // 标题
//    @Field(key: t_note_table_title)
//    var title: String?
    /// 笔记内容
    @Field(key: t_note_table_content)
    var content: String?
    
    /// user_id
    @Field(key: t_note_table_user_id)
    var userID: String?
    
    /// 笔记本id
    @Field(key: t_note_table_note_book_id)
    var noteBookID: String?
    
    /// 创建时间
    @Timestamp(key: t_note_table_create_time, on: .create, format: .unix)
    var createTime: Date?
    
    /// 更新时间
    @Timestamp(key: t_note_table_update_time, on: .update, format: .unix)
    var updateTime: Date?
    
    @Timestamp(key: t_note_table_deleted_at, on: .delete)
    var deletedAt: Date?
    
    // Creates a new, empty Galaxy.
    init() { }

    // Creates a new Galaxy with all properties set.
    init(id: UUID? = nil) {
        self.id = id ?? UUID()
    }
}

extension Note: Validatable {
    static func validations(_ validations: inout Validations) {
//        validations.add("title", as: String.self, is: .count(3...))
    }
}
