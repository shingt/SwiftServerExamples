import Swifter
import Mustache

func templatePath(path: String) -> String {
    return "./views/\(path).mustache"
}

let server = HttpServer()

server["/static/(.+)"] = HttpHandlers.directory("./static/")

server["/"] = { request in
    let documentName: String = "document"
    let path = templatePath("top")
    do {
        let template = try Template(path: path)
        let data = [
            "user": [
                "account_name": "shibuya.swift",
                "email": "hoge@email.com",
                "last_name": "Tanaka",
                "first_name": "Taro",
                "sex": "male",
                "birthday": "20001000",
                "pref": "東京",
                "friends_size": "40",
            ]
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

func getUser(user_id: Int) {
    return [
        "account_name": "shibuya.swift",
        "email": "hoge@email.com",
        "last_name": "Tanaka",
        "first_name": "Taro",
        "sex": "male",
        "birthday": "20001000",
        "pref": "東京",
        "friends_size": "40",
    ]
}

