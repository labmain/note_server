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
    // 数据库迁移（创建，更新数据表）
    app.migrations.add(Note_20210408_1_Migration())
    app.migrations.add(Notebook_20210409_4_Migration())
    app.migrations.add(User.User_20210409_1_Migration())
    app.migrations.add(UserToken.Migration())
    
    /// CORS 中间件
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)

    // Only add this if you want to enable the default per-route logging
    let routeLogging = RouteLoggingMiddleware(logLevel: .info)

    // Add the default error middleware
    let error = ErrorMiddleware.default(environment: app.environment)
    // Clear any existing middleware.
    app.middleware = .init()
    app.middleware.use(cors)
    app.middleware.use(routeLogging)
    app.middleware.use(error)
    
    // create a new JSON encoder that uses unix-timestamp dates
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .secondsSince1970

    // override the global encoder used for the `.json` media type
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    
    // register routes
    try routes(app)
    
}
