import Taylor
import Mustache

func templatePath(path: String) -> String {
    return "./views/" + path + ".mustache"
}

let server = Taylor.Server()

    server.get("/") {
        req, res, cb in

            let documentName: String = "document"
            let path = templatePath("top")
            let template = try! Template(path: path)

            let data = [
            "name": "shibuya.swift",
            "date": NSDate(),
            ]

            let rendering: String = try! template.render(Box(data))

            res.bodyString = rendering
            cb(.Send(req, res))
    }

server.get("/logout") {
    req, res, cb in

        res.bodyString = "Logout yay"
        cb(.Send(req, res))
}

server.post("/login") {
    req, res, cb in
        res.bodyString = "Login yay"
        cb(.Send(req, res))
}

let port = 3001
do {
    print("Staring server on port: \(port)")
        try server.serveHTTP(port: port, forever: true)
} catch let e {
    print("Server start failed \(e)")
}

