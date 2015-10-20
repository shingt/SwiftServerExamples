import Swifter
import Mustache

func templatePath(path: String) -> String {
    return "./views/\(path).mustache"
}

// Since I haven't figured out an easy way to connect to db in Swift  dummy data is used instead of real data..

let users: [[String: AnyObject]] = [
    [
        "id":           0,
        "account_name": "shibuya.swift",
        "nick_name":    "shibuswi",
        "email":        "hoge@email.com",
    ],
    [
        "id":           1,
        "account_name": "ichiro",
        "nick_name":    "icchian",
        "email":        "ichiro@email.com",
    ],
    [
        "id":           2,
        "account_name": "takeda",
        "nick_name":    "take",
        "email":        "take@email.com",
    ]
]

let profiles: [[String: String]] = [
    [
        "last_name":    "Swift",
        "first_name":   "Shibuya",
        "sex":          "male",
        "birthday":     "20001001",
        "pref":         "東京",
        "friends_size": "40",
    ],
    [
        "last_name":    "Tanaka",
        "first_name":   "Ichiro",
        "sex":          "male",
        "birthday":     "20001002",
        "pref":         "山形",
        "friends_size": "30",
    ],
    [
        "last_name":    "Takeda",
        "first_name":   "Jiro",
        "sex":          "male",
        "birthday":     "20001002",
        "pref":         "大阪",
        "friends_size": "20",
    ],
]

let entries: [[String: AnyObject]] = [
    [ 
        "id": "0", 
        "title": "はじめました",
        "content": "これがうわさのアレか!",
        "is_private": true,
    ],
    [ 
        "id": "1", 
        "title": "つづき",
        "content": "いやっほおおおおおおおお\nおおおおおおおおおおおおおおおおおおおおおおおおおおおおおう",
        "is_private": false,
    ],
    [ 
        "id": "2", 
        "title": "ひみつ",
        "content": "まじもう仕事がこんなことになっていようとはと思ってたら予選なしにするんだった! まじで!",
        "is_private": true,
    ],
    [ 
        "id": "3", 
        "title": "ビールのんだ",
        "content": "うまああああああああああああああああああああああああああああああああああああああああああああああああああああい!",
        "is_private": false,
    ],
]

let footprints: [[String: String]] = [
    [
        "updated":      "20151010",
        "account_name": "hoge",
        "nick_name":    "ほげ",
    ],
    [
        "updated":      "20151009",
        "account_name": "hige",
        "nick_name":    "ひげ",
    ],
    [
        "updated":      "20151008",
        "account_name": "huge",
        "nick_name":    "ふげ",
    ]
]

let comments: [[String: String]] = [
    [
        "comment": "おつ",
        "created_at":      "20151008",
    ],
    [
        "comment": "おつ",
        "created_at":      "20151008",
    ],
    [
        "comment": "おつ",
        "created_at":      "20151008",
    ],
]

func getUser(userId: Int) -> [String: AnyObject] {
    return users[userId] 
}

func getProfile(userId: Int) -> [String: String] {
    return profiles[userId]
}

func currentUser() -> [String: AnyObject] {
    let currentUserId = 0
    return getUser(currentUserId)
}

func userFromAccount(accountName: String) -> [String: AnyObject]? {
    return [
        "id":           1,
        "account_name": accountName,
        "nick_name":    "soone",
        "email":        "someone@email.com",
    ]
}

func getEntries() -> [[String: AnyObject]] {
    return entries
}

func getEntry(entry_id: Int) -> [String: AnyObject] {
    return entries[entry_id]
}

func getFootprints() -> [[String: String]] {
    return footprints
}

func getComments() -> [[String: String]] {
    return comments
}

func prefectures() -> [String] {
    return [
        "未入力",
        "北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県", "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県", "新潟県", "富山県",
        "石川県", "福井県", "山梨県", "長野県", "岐阜県", "静岡県", "愛知県", "三重県", "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県", "鳥取県", "島根県",
        "岡山県", "広島県", "山口県", "徳島県", "香川県", "愛媛県", "高知県", "福岡県", "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"
    ]
}

// pragma mark - Main - 

enum SwiftServerError: ErrorType {
    case InvalidPath
    case ResourceNotFound
    case OtherError
}

let server = HttpServer()
server["/static/(.+)"] = HttpHandlers.directory("./static/")

// /profile/:account_name
server["/profile/(.+)"] = { request in
    let path = templatePath("profile")

    do {
        let template = try Template(path: path)

        let account_name: String = request.capturedUrlGroups.last as String!
        guard let owner = userFromAccount(account_name) else {
            throw SwiftServerError.ResourceNotFound
        }

        let owner_id = owner["id"] as! Int
        let profile = getProfile(owner_id)
        let entries = getEntries()
        let current_user = currentUser()
        let myself = owner_id == current_user["id"] as! Int

        let data = [
            "owner": owner,
            "profile": profile,
            "entries": entries,
            "private": true,
            "is_friend": false,
            "current_user": currentUser(),
            "prefectures": prefectures(),
            "myself": myself,
        ]
        let rendering: String = try template.render(Box(data))

        return .OK(.HTML(rendering))
    } catch SwiftServerError.ResourceNotFound {
        return .BadRequest
    } catch {
        return .InternalServerError
    }
}

// /diary/entrries/:account_name
server["/diary/entries/(.+)"] = { request in
    let path = templatePath("entries")

    do {
        let template = try Template(path: path)
        
        let account_name: String = request.capturedUrlGroups.last as String!
        guard let owner = userFromAccount(account_name) else {
            throw SwiftServerError.ResourceNotFound
        }

        let owner_id = owner["id"] as! Int
        let entries = getEntries()
        let current_user = currentUser()
        let myself = owner_id == current_user["id"] as! Int
        let comments = getComments()

        let data = [
            "owner":   owner,
            "entries": entries,
            "myself":  myself,
            "comment_count": comments.count,
        ]
        let rendering: String = try template.render(Box(data))

        return .OK(.HTML(rendering))
    } catch SwiftServerError.ResourceNotFound {
        return .BadRequest
    } catch {
        return .InternalServerError
    }
}

// /diary/entry/:entry_id
server["/diary/entry/(.+)"] = { request in
    let path = templatePath("entry")

    do {
        let template = try Template(path: path)

        guard let entry_id: Int = Int(request.capturedUrlGroups.last as String!) else {
            throw SwiftServerError.InvalidPath
        }

        let account_name = "someone"  // FIX: getUser
        guard let owner = userFromAccount(account_name) else {
            throw SwiftServerError.ResourceNotFound
        }

        let entry = getEntry(entry_id)
        let comments = getComments()

        let data = [
            "owner": owner,
            "entry": entry,
            "comments": comments,
        ]
        let rendering: String = try template.render(Box(data))

        return .OK(.HTML(rendering))
    } catch SwiftServerError.InvalidPath {
        return .BadRequest
    } catch SwiftServerError.ResourceNotFound {
        return .BadRequest
    } catch {
        return .InternalServerError
    }
}

server["/"] = { request in
    let path = templatePath("top")

    do {
        let template = try Template(path: path)

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
            "comments_of_friends": comments_of_friends,
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

