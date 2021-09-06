import UIKit

class ResultAlert: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
        
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var reBattle: UIButton!
    @IBOutlet weak var exit: UIButton!
    
    @IBOutlet weak var titleBtn: UIButton!
    
    var winnerName = ""
    var winnerImg = ""
    var parentController:UIViewController?
    var dUser:User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey: "user") as? Data)!)
        print(dUser!)
        
        userImage.layer.borderWidth = 2
        userImage.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
        userImage.layer.cornerRadius = userImage.bounds.width / 2
        userImage.clipsToBounds = true
        
        if winnerName == "\(Apps.MATCH_DRAW)" {
            userName.text = "\(winnerName) \n \(Apps.GAME_OVER)"
            titleBtn.setTitle(Apps.APP_NAME, for: .normal)
        }else if winnerName == dUser?.name {
            userName.text = "\(winnerName) , \(Apps.WIN_BATTLE)"
            titleBtn.setTitle(Apps.CONGRATS, for: .normal)
        }else{
            userName.text = "\(winnerName) \(Apps.OPP_WIN_BATTLE)"
            titleBtn.setTitle(Apps.LOSE_BATTLE, for: .normal)
        }
                
        if winnerName == "Robot"{
            userImage.image = UIImage(named: "robot")
        }else{
            if !winnerImg.isEmpty {
                DispatchQueue.main.async {
                    self.userImage.loadImageUsingCache(withUrl: self.winnerImg)
                }
            }
        }
        
        reBattle.setBorder()
        exit.layer.cornerRadius = exit.frame.height / 3
    }
    
    @IBAction func RebattleBtn(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("CloseRobotPlay"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("CheckBattle"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("CompleteBattle"), object: nil)
        parentController?.dismiss(animated: true, completion: nil)        
        self.dismiss(animated: true, completion: nil)
}
    
    @IBAction func BattleExitBtn(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("CompleteBattle"), object: nil)// call this function to clear data to firebase
        NotificationCenter.default.post(name: Notification.Name("CloseRobotPlay"), object: nil)// this will close if user play with robot to close robotplayviewcontroller
        NotificationCenter.default.post(name: Notification.Name("CloseBattleViewController"), object: nil)
        parentController?.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
}
