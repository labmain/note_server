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
        try Note.validate(content: req)
        let n = try req.content.decode(Note.self)
        let note = Note(title: n.title)
        let re = note.save(on: req.db).map { print("Product saved") }
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
    
    app.post("notebook") { (req) -> HTTPResponseStatus in
        try Notebook.validate(content: req)
        let n = try req.content.decode(Notebook.self)
        let notebook = Notebook(name: n.name)
        notebook.noteList = n.noteList
        let re = notebook.save(on: req.db).map { print("Product saved") }
        re.whenFailure { (error) in
            print(error)
        }
        re.whenSuccess { (success) in
            print(success)
        }
        return HTTPResponseStatus.ok
    }
    

}
