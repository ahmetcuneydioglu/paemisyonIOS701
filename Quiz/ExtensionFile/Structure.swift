import Foundation

//structure for store user default data
struct User:Codable{
    var UID:String
    var userID:String
    var name:String
    var email:String
    var phone:String
    var address:String
    var userType:String
    var image:String
    var status:String
    
    var ref_code:String    
}

// user score related structure
struct UserScore:Codable{
    var coins:Int
    var points:Int
}

//app notification structure
struct Notifications: Codable {
    var title:String
    var msg:String
    var img:String
}

//apps setting structure
struct  Setting:Codable {
    var sound:Bool
    var backMusic:Bool
    var vibration:Bool
}

struct contestQuestion: Codable {
    var id:String
    var contest_id:String
    var question:String
    var optionA:String
    var optionB:String
    var optionC:String
    var optionD:String
    var optionE:String
    var correctAns:String
    var image:String
    var note:String
    var quesType:String   
}

struct QuestionWithE: Codable {
    var id:String
    var question:String
    var optionA:String
    var optionB:String
    var optionC:String
    var optionD:String
    var optionE:String
    var correctAns:String
    var image:String
    var level:String
    var note:String
    var quesType:String
    
    var toDictionaryE: [String:String]{
    return [        "id":id,"question":question,"optionA":optionA,"optionB":optionB,"optionC":optionC,"optionD":optionD,"optionE":optionE,"correctAns":correctAns,"image":image,"level":level,"note":note,"quesType":quesType
           ]
    }
}

struct Question: Codable {
    var id:String
    var question:String
    var optionA:String
    var optionB:String
    var optionC:String
    var optionD:String
    var correctAns:String
    var image:String
    var level:String
    var note:String
    var quesType:String
    
    var toDictionary: [String:String]{
        return [
            "id":id,"question":question,"optionA":optionA,"optionB":optionB,"optionC":optionC,"optionD":optionD,"correctAns":correctAns,"image":image,"level":level,"note":note,"quesType":quesType
        ]
    }
}

struct ReQuestion {
    let id:String
    let question:String
    let optionA:String
    let optionB:String
    let optionC:String
    let optionD:String
    let correctAns:String
    let image:String
    let level:String
    let note:String
    var quesType:String
    let userSelect:String
    
}

struct ReQuestionWithE {
    let id:String
    let question:String
    let optionA:String
    let optionB:String
    let optionC:String
    let optionD:String
    let optionE:String
    let correctAns:String
    let image:String
    let level:String
    let note:String
    var quesType:String
    var userSelect:String
}

struct SystemConfiguration:Codable{
    var LANGUAGE_MODE = 0
}

struct Language:Codable{
    let id:Int
    let name:String
    let status:Int
}

struct BattleStatistics:Codable{
    
    let oppID:String
    let oppName:String
    let oppImage:String
    let battleStatus:String
    let battleDate:String
    
}
//=============Battle Structures===============
struct OnlineUser:Codable{
    
    let uID:String
    let userID:String
    let userName:String
    let userImage:String
    let status:String
    
}

struct JoinedUser:Codable{
    
    let uID:String
    let userID:String
    let userName:String
    let userImage:String
    var isJoined:Bool
    var rightAns:String
    var wrongAns:String
    var isLeave:Bool? = false

}

struct RoomDetails:Codable{
    var ID:String
    let roomFID:String
    let userID:String
    let roomName:String
    let catName:String
    let catLavel:String
    let noOfPlayer:String
    let noOfQues:String
    let playTime:String
}

//=============== constance variable ===========

let DEFAULT_SYS_CONFIG = "SystemConfig"
let DEFAULT_LANGUAGE = "LanguageList"
let DEFAULT_USER_LANG = "LanguageID"
let API_LANGUAGE_LIST = "get_languages"
