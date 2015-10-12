import Swifter
import Mustache

func templatePath(path: String) -> String {
    return "./views/\(path).mustache"
}

func getUser(userId: Int) -> [String: AnyObject] {
    return [
        "id":           userId,
        "account_name": "shibuya.swift",
        "email":        "hoge@email.com",
    ]
}

func getProfile(userId: Int) -> [String: String] {
    return [
        "last_name":    "Tanaka",
        "first_name":   "Taro",
        "sex":          "male",
        "birthday":     "20001000",
        "pref":         "東京",
        "friends_size": "40"
    ]
}

func currentUser() -> [String: AnyObject] {
    let currentUserId = 0
    return getUser(currentUserId)
}

func getEntries() -> [[String: String]] {
    return [
        [ 
            "id": "1", 
            "title": "はじめました"
        ],
        [ 
            "id": "2", 
            "title": "つづき"
        ],
        [ 
            "id": "3", 
            "title": "ひみつ"
        ],
        [ 
            "id": "4", 
            "title": "ビールのんだ"
        ]
    ]
}

func getFootprints() -> [[String: String]] {
    return [
        [
            "updated":      "20151010",
            "account_name": "hoge",
            "nick_name":    "ほげ"
        ],
        [
            "updated":      "20151009",
            "account_name": "hige",
            "nick_name":    "ひげ"
        ],
        [
            "updated":      "20151008",
            "account_name": "huge",
            "nick_name":    "ふげ"
        ]
    ]
}

let uppercase = Filter { (rendering: Rendering) in
    let reversedString = String(rendering.string.characters.reverse())
        return Rendering(reversedString, rendering.contentType)
}


let server = HttpServer()

server["/static/(.+)"] = HttpHandlers.directory("./static/")

server["/"] = { request in
    let documentName: String = "document"
    let path = templatePath("top")
    do {
        let template = try Template(path: path)
        template.registerInBaseContext("uppercase", Box(uppercase))

        let user = currentUser()
        let profile = getProfile(user["id"] as! Int)
        let entries = getEntries()
        let footprints = getFootprints()
        let comments_for_me = ["fixme": "fixme"]
        let entries_of_friends = ["fixme": "fixme"]
        let comments_of_friends = ["fixme": "fixme"]

        let data = [
            "user": user,
            "profile": profile,
            "entries": entries,
            "footprints": footprints,
            "comments_for_me": comments_for_me,
            "entries_of_friends": entries_of_friends,
            "comments_of_friends": comments_of_friends
//        'friends' => $friends,
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

