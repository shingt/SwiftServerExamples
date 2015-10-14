import Swifter
import Mustache

func templatePath(path: String) -> String {
    return "./views/\(path).mustache"
}

// As I couldn't figure out the easy way to connect to db functions themselves containe data..

func getUser(userId: Int) -> [String: AnyObject] {
    return [
        "id":           userId,
        "account_name": "shibuya.swift",
        "nick_name":    "shibuswi",
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
        "friends_size": "40",
    ]
}

func currentUser() -> [String: AnyObject] {
    let currentUserId = 0
    return getUser(currentUserId)
}

func userFromAccount(accountName: String) -> [String: AnyObject] {
    return [
        "id":           1,
        "account_name": accountName,
        "nick_name":    "soone",
        "email":        "someone@email.com",
    ]
}

func getEntries() -> [[String: AnyObject]] {
    return [
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
}

func getEntry(entry_id: Int) -> [String: AnyObject] {
    return [
        "id": "3", 
        "title": "ビールのんだ",
        "content": "うまああああああああああああああああああああああああああああああああああああああああああああああああああああい!",
        "is_private": false,
    ]
}

func getFootprints() -> [[String: String]] {
    return [
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

let server = HttpServer()

server["/static/(.+)"] = HttpHandlers.directory("./static/")

server["/profile/(.+)"] = { request in
    let path = templatePath("profile")

    do {
        let template = try Template(path: path)

        let account_name = "someone"
        let owner = userFromAccount(account_name)
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
    } catch {
        return .InternalServerError
    }
}

server["/diary/entries/(.+)"] = { request in
    let path = templatePath("entries")

    do {
        let template = try Template(path: path)

        let account_name = "someone"
        let owner = userFromAccount(account_name)
        let owner_id = owner["id"] as! Int
        let entries = getEntries()
        let current_user = currentUser()
        let myself = owner_id == current_user["id"] as! Int

        let data = [
            "owner":   owner,
            "entries": entries,
            "myself":  myself,
        ]
        let rendering: String = try template.render(Box(data))

        return .OK(.HTML(rendering))
    } catch {
        return .InternalServerError
    }
}

server["/diary/entry/(.+)"] = { request in
    let path = templatePath("entry")

    do {
        let template = try Template(path: path)

        let entry_id: Int? = Int(request.capturedUrlGroups.last as String!)
        let account_name = "someone"
        let owner = userFromAccount(account_name)
        let entry = getEntry(entry_id!)

        let data = [
            "owner": owner,
            "entry": entry,
//            comments: comments,
        ]
        let rendering: String = try template.render(Box(data))

        return .OK(.HTML(rendering))
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

