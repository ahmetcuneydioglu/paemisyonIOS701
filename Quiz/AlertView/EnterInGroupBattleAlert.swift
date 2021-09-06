import UIKit
import FirebaseDatabase

class EnterInGroupBattleAlert: UIViewController, UITextFieldDelegate  {
    
    @IBOutlet weak var joinRoomBtn: UIButton!
    @IBOutlet weak var gameCodeTxt: UITextField!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    var ref: DatabaseReference!
    var roomList:[RoomDetails] = []
    var availRooms = ["00000","11111"]
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        gameCodeTxt.attributedPlaceholder = NSAttributedString(string:Apps.P_GAMECODE, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        self.hideKeyboardWhenTappedAround()
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 600)
        
        joinRoomBtn.layer.cornerRadius = joinRoomBtn.frame.height / 2
        gameCodeTxt.layer.cornerRadius = gameCodeTxt.frame.height / 2
        gameCodeTxt.clipsToBounds = true
        gameCodeTxt.backgroundColor = UIColor.cyan.withAlphaComponent(0.6)
        
        bgView.layer.cornerRadius = 25
        
        ref = Database.database().reference().child("MultiplayerRoom")
     }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0,y: textField.center.y-40), animated: true)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        scrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
    }
    func checkForAvailability(){
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
             if let data = snapshot.value as? [String:Any]{
                print(data)
                self.roomList.removeAll()
                self.availRooms.removeAll()
                for val in data{
                    self.availRooms.append(val.key)
                }
                  if self.availRooms.contains(self.gameCodeTxt.text!){
                    print("game code found")
                    for val in data{
                        if self.gameCodeTxt.text == val.key {
                            print(val.key)
                            if let room = val.value as? [String:Any]{
                                if ("\(room["isRoomActive"] ?? "true")".bool ?? true){
//                                    print(room["isStarted"]!)
                                    if !("\(room["isStarted"] ?? "true")".bool ?? true){
                                        if let roomUser = room["roomUser"] as? [String:Any]{
                                        self.roomList.append(RoomDetails.init(ID: "\(room["authId"]!)", roomFID: "\(self.gameCodeTxt.text ?? "0000")", userID: "\(roomUser["userID"]!)", roomName: "", catName: "", catLavel: "0", noOfPlayer: "", noOfQues: "0", playTime: ""))
                                        print("true - enter in room - \(self.roomList)")
                                        self.gotoGroupBattleView()
                                        return
                                        }
                                    }else{
                                        DispatchQueue.main.async {
                                            self.ShowAlert(title: Apps.GAME_CLOSED, message: "")
                                            self.CloseAlert(self)
                                        }
                                    }
                                }else{
                                print("Is room active - false")
                                DispatchQueue.main.async {
                                    self.ShowAlert(title: Apps.GAME_CLOSED, message: "")
                                    self.CloseAlert(self) 
                                    }
                                }
                          }
                        }else{
                          //  print("entered roomcode match not found")
                        }
                    }
                }else{
                    print("gameCode not found")
                    self.ShowAlert(title: Apps.GAMECODE_INVALID, message: "")
                } //if of gamecodeText
            }
        })
    }
    func gotoGroupBattleView(){
        //go to Group battle view & add yourself with group of people present there
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "GroupBattleView") as! GroupBattleView
        viewCont.isUserJoininig = true
        viewCont.gameRoomCode = self.gameCodeTxt.text ?? "00000"
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    @IBAction func CloseAlert(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func GoToRoom(_ sender: Any) {
        if gameCodeTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
             gameCodeTxt.placeholder = Apps.GAMEROOM_ENTERCODE
        }else{
            checkForAvailability()
        }
    }
}
