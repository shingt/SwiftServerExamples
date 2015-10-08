import Swifter
import Mustache

func templatePath(path: String) -> String {
    return "./views/\(path).mustache"
}

let server = HttpServer()

server["/"] = { request in
    let documentName: String = "document"
    let path = templatePath("top")
    do {
        let template = try Template(path: path)
        let data = [
        "name": "shibuya.swift",
        "date": NSDate(),
        ]
        let rendering: String = try template.render(Box(data))
        return .OK(.HTML(rendering))
    } catch {
        return .InternalServerError
    }
}

var error: NSError?

let port: UInt16 = 3002
if !server.start(port, error: &error) {
    print("Server start error: \(error)")
} else {
    print("Server started on port: \(port)")
    NSRunLoop.mainRunLoop().run()
}

