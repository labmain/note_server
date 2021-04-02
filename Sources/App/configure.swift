import Vapor
import Fluent
import FluentMySQLDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.databases.use(.mysql(
        hostname: "localhost",
        username: "note",
        password: "FcG29CHnhuP-8wDmJ4qz.okYs",
        database: "note_db",
        tlsConfiguration: .forClient(certificateVerification: .none)
    ), as: .mysql)
    // register routes
    try routes(app)
    
}
