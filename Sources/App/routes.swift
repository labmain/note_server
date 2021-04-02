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
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> [String: String] in
        let hello = try req.query.decode(Hello.self)
        return ["name": hello.name ?? "xxxx", "b": "bbb"]
    }
    app.get("note") { req -> EventLoopFuture<[Note]> in
        return Note.query(on: req.db).all()
    }
    
    app.post("note") { (req) -> HTTPResponseStatus in
        let n = try req.query.decode(PostNote.self)
        let note = Note(title: n.title ?? "title")
        let re = note.save(on: req.db).map { print("Product saved") }
        re.whenFailure { (error) in
            print(error)
        }
        re.whenSuccess { (success) in
            print(success)
        }
        return HTTPResponseStatus.ok
    }

}
