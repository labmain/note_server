import Vapor
import Fluent
import FluentMySQLDriver
struct Hello: Content {
    var name: String?
}
struct PostNote: Content {
    var title: String?
}
func routes(_ app: Application) throws {
    struct NoteJSON: Content {
//        var hello: String
        var id: UUID?
        
        // 标题
        var title: String
        /// 笔记内容
        var content: String?
        
        /// user_id
        var userID: String?
        
        /// 笔记本id
        var noteBookID: String?
        
        /// 创建时间
        var createTime: Date?
        
        /// 更新时间
        var updateTime: Date?
    }
    

    let protected = app.grouped(User.authenticator())
        .grouped(User.guardMiddleware())
    
    app.get("note") { req -> EventLoopFuture<[Note]> in
        let notebookID: String? = req.query["notebookID"]
        guard notebookID != nil else {
           return Note.query(on: req.db).all()
        }
        return Note.query(on: req.db).filter(\.$noteBookID == notebookID ?? "").all()
    }
    
    app.post("note") { (req) -> HTTPResponseStatus in
        try Note.validate(content: req)
        let n = try req.content.decode(Note.self)
        guard n.id != nil && n.content != nil && n.noteBookID != nil else {
            return HTTPResponseStatus.noContent
        }
        Note.query(on: req.db).filter(\.$id == n.id!).count().whenSuccess { (count) in
            if count > 0 {
               let re = Note.query(on: req.db)
                    .set(\.$content, to: n.content)
                    .filter(\.$id == n.id!)
                    .update()
                re.whenFailure { (error) in
                    print(error)
                }
                re.whenSuccess { (success) in
                    print(success)
                }
            } else {
              let re = n.save(on: req.db).map { print("Note saved") }
                re.whenFailure { (error) in
                    print(error)
                }
                re.whenSuccess { (success) in
                    print(success)
                }
            }
        }
        return HTTPResponseStatus.ok
    }
    
    app.delete("note") { (req) -> HTTPResponseStatus in
        let n = try req.content.decode(Note.self)
        guard n.id != nil else {
            return HTTPResponseStatus.noContent
        }
        let re =  n.delete(on: req.db).map { print("Note deleted") }
        re.whenFailure { (error) in
            print(error)
        }
        re.whenSuccess { (success) in
            print(success)
        }
        return HTTPResponseStatus.ok
    }
    
    app.get("notebook") { req -> EventLoopFuture<[Notebook]> in
        return Notebook.query(on: req.db).all()
    }
    /// 检查笔记本名字
    app.get("notebook","check") { req -> EventLoopFuture<Dictionary<String, String>> in
        let name: String? = req.query["name"]
        return Notebook.query(on: req.db).filter(\.$name == name ?? "").first().map{ obj in
            if obj != nil {
                return ["isHas": "1"]
            }
            return ["isHas": "0"]
        }
    }
    
    app.post("notebook") { (req) -> HTTPResponseStatus in
        try Notebook.validate(content: req)
        let notebook = try req.content.decode(Notebook.self)
        let re = notebook.save(on: req.db).map { print("Notebook saved") }
        re.whenFailure { (error) in
            print(error)
        }
        re.whenSuccess { (success) in
            print(success)
        }
        return HTTPResponseStatus.ok
    }
    
    app.post("users") { req -> EventLoopFuture<User> in
        try User.Create.validate(content: req)
        let create = try req.content.decode(User.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let user = try User(
            name: create.name,
            passwordHash: Bcrypt.hash(create.password)
        )
        return user.save(on: req.db)
            .map { user }
    }
    
    // 登录验证
    let passwordProtected = app.grouped(User.authenticator())
    passwordProtected.post("login") { req -> EventLoopFuture<User.UserInfo> in
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        
        return token.save(on: req.db)
            .map { ttt in
                return User.UserInfo(id: user.id?.uuidString ?? "", name: user.name, token: token.value)
                
            }
    }
    
    let tokenProtected = app.grouped(UserToken.authenticator())
    tokenProtected.get("me") { req -> User in
        try req.auth.require(User.self)
    }
    
    passwordProtected.get("logout") { req -> HTTPResponseStatus in
        req.auth.logout(User.self)
        return HTTPResponseStatus.ok
    }


}
