//
//  File.swift
//  
//
//  Created by shun on 2021/4/5.
//
import Foundation
import Fluent
import FluentMySQLDriver
import Vapor

let t_notebook_table_name: FieldKey = "name"
let t_notebook_table_note_list: FieldKey = "note_list"
let t_notebook_table_note_type: FieldKey = "type"
let t_notebook_table_user_id: FieldKey = "user_id"
let t_notebook_table_create_time: FieldKey = "create_time"
let t_notebook_table_update_time: FieldKey = "update_time"
let t_notebook_table_deleted_at: FieldKey = "deleted_at"

struct Notebook_20210405_7_Migration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.enum("NoteBookType")
            .case("my_self")
            .case("normal")
            .create()
            .flatMap { type in
                database.schema("notebooks")
                    .id()
                    .field(t_notebook_table_name, .string, .required)
                    .field(t_notebook_table_note_list, .array(of: .uuid))
                    .field(t_notebook_table_user_id, .string)
                    .field(t_notebook_table_create_time, .double)
                    .field(t_notebook_table_update_time, .double)
                    .field(t_notebook_table_deleted_at, .double)
                    .field(t_notebook_table_note_type, type, .required, .custom("DEFAULT 'normal'"))
                    .create()
            }
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("notebooks").delete()
    }
}
enum NoteBookType: String, Codable {
    case mySelf
    case normal
}
final class Notebook: Model, Content {
    
    // 表名
    static let schema = "notebooks"

    // 主键
    @ID(key: .id)
    var id: UUID?

    // 笔记本名称
    @Field(key: t_notebook_table_name)
    var name: String
    /// 笔记内容
    @Field(key: t_notebook_table_note_list)
    var noteList: [UUID]?
    
    @Enum(key: t_notebook_table_note_type)
    var type: NoteBookType
    /// user_id
    @Field(key: t_notebook_table_user_id)
    var userID: String?
    
    /// 创建时间
    @Timestamp(key: t_notebook_table_create_time, on: .create, format: .unix)
    var createTime: Date?
    
    /// 更新时间
    @Timestamp(key: t_notebook_table_update_time, on: .update, format: .unix)
    var updateTime: Date?
    
    @Timestamp(key: t_notebook_table_deleted_at, on: .delete)
    var deletedAt: Date?
    
    // Creates a new, empty Galaxy.
    init() { }

    // Creates a new Galaxy with all properties set.
    init(id: UUID? = nil, name: String, type: NoteBookType? = .normal) {
        self.id = id ?? UUID()
        self.name = name
        self.type = type ?? .normal
    }
    
//    public static func getFirstNote(req: Request) -> Note? {
//        let note = Note.query(on: req.db).first()
//        return Note.query(on: req.db).first()
//    }
}

extension Notebook: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: .count(1...))
        validations.add("noteList", as: Array<UUID>.self)
    }
}

