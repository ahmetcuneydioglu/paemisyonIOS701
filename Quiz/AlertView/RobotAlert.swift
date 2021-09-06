import UIKit
import FirebaseDatabase

protocol RobotDelegate {
   func playWithRobot()
}

class RobotAlert: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var playWithRobot: UIButton!
    @IBOutlet weak var tryAgain: UIButton!
    
    var imageUrl = ""
    var parentController:UIViewController?
    var robotDelegate:RobotDelegate?
    
    var battleSelection = BattleViewController()
    var ref: DatabaseReference!
    var user:User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference().child("RandomBattleRoom")
        
        userImage.layer.borderWidth = 2
        userImage.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
        userImage.layer.cornerRadius = userImage.bounds.width / 2
        userImage.clipsToBounds = true
        
        if !imageUrl.isEmpty{
            userImage.loadImageUsingCache(withUrl: imageUrl)
        }
        
         NotificationCenter.default.addObserver(self,selector: #selector(self.DismissAlert),name: NSNotification.Name(rawValue: "DismissAlert"),object: nil)
        
        mainView.SetShadow()
        tryAgain.layer.cornerRadius = tryAgain.frame.height / 3
        playWithRobot.setBorder()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func PlayWithRobot(_ sender: Any) {
        if battleSelection.timer != nil && battleSelection.timer.isValid{
            battleSelection.timer.invalidate()
        }
        user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        self.ref.child(self.user.UID).removeValue()
        self.ref.removeAllObservers()
        self.dismiss(animated: true, completion: {
            self.robotDelegate?.playWithRobot()
        })
    }
    
    @IBAction func TryAgainBtn(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("CompleteBattle"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("CheckBattle"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
   
    @IBAction func ExitBtn(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("CloseBattleViewController"), object: nil)
        parentController?.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func DismissAlert(){
        self.dismiss(animated: true, completion: nil)
    }
}
