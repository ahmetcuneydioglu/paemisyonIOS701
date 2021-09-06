import Foundation
import UIKit
import FirebaseDatabase

// create battle user structer to get user's information
struct BattleUser {
    let UID:String
    let userID:String
    let name:String
    let image:String
    let matchingID:String
    
    let cateId:String
    let langId:String
    
}
class BattleViewController: UIViewController {
    
    @IBOutlet var user1: UIImageView!
    @IBOutlet var user2: UIImageView!
    @IBOutlet var vsImg: UIImageView!
    @IBOutlet var name1: UILabel!
    @IBOutlet var name2: UILabel!
    
    @IBOutlet weak var player2View: UIView!
    
    @IBOutlet weak var searchButton:UIButton!
    
    var ref: DatabaseReference!
    var timer:Timer!
    var seconds = 10
    
    var battleUser:BattleUser!
    var isAvail = false
    var user:User!
    
    var DataList:[BattleStatistics] = []
    var Loader: UIAlertController = UIAlertController()
    
    var isCategoryBattle = false
    var catID = 0
    var langID = "-1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player2View.alpha = 0
        vsImg.alpha = 0
        
        vsImg.layer.cornerRadius = 20
        vsImg.SetShadow()
        
        vsImg.center.x = self.view.center.x
        searchButton.layer.cornerRadius = 8
        searchButton.layer.masksToBounds = true
        self.ref = Database.database().reference().child("RandomBattleRoom")
        
        self.DesignViews(views: user1,user2)
        
        //register nsnotification for latter call
        NotificationCenter.default.addObserver(self,selector: #selector(self.QuitBattle),name: NSNotification.Name(rawValue: "QuitBattle"),object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.CheckForBattle),name: NSNotification.Name(rawValue: "CheckBattle"),object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.CloseThisController),name: NSNotification.Name(rawValue: "CloseBattleViewController"),object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.ResetToBattleCheck),name: NSNotification.Name(rawValue: "ResetBattle"),object: nil)
        
        user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        self.ref.child("RandomBattleRoom").child(user.UID).removeValue()
        
        //set value for this user
        name1.text = user.name
        DispatchQueue.main.async {
            self.user1.loadImageUsingCache(withUrl: self.user.image)
        }
        
        //get data from server
        if(Reachability.isConnectedToNetwork()){
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.isSearchingStart{
            self.imgAnimation()
        }
    }
    
    @IBAction func settingButton(_ sender: Any) {
        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
    
    //load category data here
    func LoadData(jsonObj:NSDictionary){
        let status = Bool(jsonObj.value(forKey: "error") as! String)
        if (status!) {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                })
            }
        }else{
            //get data for category
            DataList.removeAll()
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    DataList.append(BattleStatistics.init(oppID: "\(val["opponent_id"]!)", oppName: "\(val["opponent_name"]!)", oppImage: "\(val["opponent_profile"]!)", battleStatus: "\(val["mystatus"]!)", battleDate: "\(val["date_created"]!)"))
                }
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
            }
        });
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.ref.removeAllObservers()
    }
    
    // function to close this controller by nsnotification
    @objc func CloseThisController(){
        if timer != nil && timer.isValid{
            timer.invalidate()
        }
        // remove user data from firebase database
        self.ref.child(self.user.UID).removeValue()
        self.ref.removeAllObservers()
        self.navigationController?.popViewController(animated: true)
    }
    // check for battle
    @objc func CheckForBattle(){
        imgAnimation()
        self.seconds = 10
        self.searchButton.isHidden = true
        
        if UserDefaults.standard.value(forKey: DEFAULT_USER_LANG) != nil{
            langID = UserDefaults.standard.string(forKey: DEFAULT_USER_LANG) ?? "-1"
        }

        var userDetails:[String:String] = [:]
        userDetails["userID"] = self.user.userID
        userDetails["name"] = self.user.name
        userDetails["image"] = self.user.image
        userDetails["isAvail"] = "1"
        userDetails["cateId"] = String(self.catID)
        userDetails["langId"] = self.langID
        // set data for available to battle with users in firebase database
        self.ref.child(user.UID).setValue(userDetails)
        
        self.battleUser = nil
        self.isBattlePlay = false
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
        
        // check if user is avalable for battle
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            for fuser in (snapshot.children.allObjects as? [DataSnapshot])!{
                let data = fuser.value as? [String:String]
                if (data?["isAvail"]) != nil{
                    if((data?["isAvail"])! == "1" && fuser.key != self.user.UID && (data?["cateId"])! == String(self.catID) && (data?["langId"])! == self.langID) {
                        self.battleUser = BattleUser.init(UID: "\(fuser.key)", userID: "\((data?["userID"])!)", name: "\((data?["name"])!)", image: "\((data?["image"])!)",matchingID: "\(self.user.UID)",cateId: "\((data?["cateId"])!)",langId: "\((data?["langId"])!)")
                        self.isAvail = true
                    }
                }
            }
            if(self.isAvail){
                // if user is avalable for battle set its value for second user
                self.name2.text = self.battleUser.name
                DispatchQueue.main.async {
                    self.user2.loadImageUsingCache(withUrl: self.battleUser.image)
                }
                var oppVal = ["":""]
                oppVal["isAvail"] = "0"
                oppVal["opponentID"] = self.user.UID
                oppVal["matchingID"] = self.user.UID
                
                self.ref.child(self.battleUser.UID).child("matchingID").setValue(self.user.UID)
                self.ref.child(self.battleUser.UID).child("isAvail").setValue("0")
                self.ref.child(self.battleUser.UID).child("opponentID").setValue(self.user.UID)
               
                self.ref.child(self.user.UID).child("matchingID").setValue(self.user.UID)
                self.ref.child(self.user.UID).child("isAvail").setValue("0")
                self.ref.child(self.user.UID).child("opponentID").setValue(self.battleUser.UID)
                
                
                self.timer.invalidate()
                self.StartBattle()
            }else{
               
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        //set value when opponent select you for battle and get opponent name and image url
        ref.child(user.UID).observe(.value, with: {(snapshot) in
            
            if(snapshot.hasChild("isAvail") && snapshot.childSnapshot(forPath: "isAvail").value! as! String == "0"){
                if snapshot.hasChild("opponentID") && snapshot.hasChild("matchingID"){
                    let opponentID = snapshot.childSnapshot(forPath: "opponentID").value! as! String
                    if (opponentID != ""){
                        self.ref.child(opponentID).observeSingleEvent(of: .value, with: {(battleSnap) in
                            // this user is avalable for battle
                            if battleSnap.hasChild("matchingID"){
                                self.battleUser = BattleUser.init(UID: "\(battleSnap.key)", userID: "\(battleSnap.childSnapshot(forPath: "userID").value!)", name: "\(battleSnap.childSnapshot(forPath: "name").value!)", image: "\(battleSnap.childSnapshot(forPath: "image").value!)",matchingID: "\(battleSnap.childSnapshot(forPath: "matchingID").value!)",cateId: "\(battleSnap.childSnapshot(forPath: "cateId").value!)",langId: "\(battleSnap.childSnapshot(forPath: "langId").value!)")
                                self.isAvail = true
                                print("BBB",battleSnap.childSnapshot(forPath: "matchingID").value!)
                                self.name2.text = "\(battleSnap.childSnapshot(forPath: "name").value!)"
                                DispatchQueue.main.async {
                                    self.user2.loadImageUsingCache(withUrl: "\(battleSnap.childSnapshot(forPath: "image").value!)")
                                }
                                self.StartBattle()
                            }else{
                                print("MATCH NULLLL")
                            }
                        })
                    }
                }
            }else{
                self.isAvail = false
            }
        })
    }
    
    @objc func incrementCount() {
        seconds -= 1
        if seconds < 0 {
            // invalidate timer and no user is avalable for battle
            self.ResetToBattleCheck()
            self.ShowRobotAlert()
        }
    }
    
    //call this function when user gone or exist from battle
    @objc func QuitBattle(){
        if timer != nil && timer.isValid{
            timer.invalidate()
        }
        // remove user data from firebase database
        self.ref.removeAllObservers()
        if self.user == nil || self.battleUser == nil{
            return
        }
        if(Reachability.isConnectedToNetwork()){
            var apiURL = "user_id1=\(self.user.UID)&user_id2=\(self.battleUser.UID)&match_id=\(self.battleUser.matchingID)&destroy_match=1"
            if isCategoryBattle == true {
                apiURL += "&category=\(catID)"
            }
            self.getAPIData(apiName: "get_random_questions", apiURL: apiURL,completion: {_ in })
        }
    }
    
    @objc func ResetToBattleCheck(){
        self.ref.child(user.UID).child("isAvail").setValue("0")
        timer.invalidate()
      
        self.isSearchingStart = false
        self.vsImg.layer.removeAllAnimations()
        self.seconds = 10
        self.searchButton.isHidden = false
    }
    // set Custom Design function
    func DesignViews(views:UIView...){
        for view in views{
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.white.cgColor
            view.layer.cornerRadius = view.frame.height / 2 
            view.clipsToBounds = true
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        let alert = UIAlertController(title: "", message: Apps.LEAVE_MSG, preferredStyle: UIAlertController.Style.alert)
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertAction.Style.default, handler: nil))
            alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertAction.Style.destructive, handler: { action in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            alert.view.tintColor = UIColor.red //alert Action font color changes to red
    }
    
    func imgAnimation(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat,.autoreverse,UIView.AnimationOptions.curveEaseIn,], animations: {
            self.vsImg.transform = CGAffineTransform.identity.scaledBy(x: 1.3, y: 1.3) // Scale your image
         }) { (finished) in
             UIView.animate(withDuration: 1, animations: {
              self.vsImg.transform = CGAffineTransform.identity // undo
           })
        }
    }
    
    var isSearchingStart = false
    @IBAction func CheckBattleButton(_ sender:UIButton){
        
        player2View.alpha = 1
        vsImg.alpha = 1
        
        if(!Reachability.isConnectedToNetwork()){
            self.ShowAlert(title: Apps.NO_INTERNET_TITLE, message: Apps.NO_INTERNET_MSG)
            return
        }
        sender.isHidden = true
        
        if isSearchingStart{
            return
        }
        self.isSearchingStart = true
        if self.isSearchingStart{
          
        }
        self.CheckForBattle()
    }
    //start battle and pass data to battleplaycontroller
    var isBattlePlay = false
    func StartBattle(){
        self.isSearchingStart = false
    
        if self.timer.isValid{
            self.timer.invalidate()
        }
        if isBattlePlay{
            return
        }
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "BattlePlayController") as! BattlePlayController
        viewCont.battleUser = self.battleUser
        self.isBattlePlay = true
        self.isSearchingStart = false
        self.searchButton.isHidden = false
        viewCont.isCategoryBattle = self.isCategoryBattle
        viewCont.catID = self.catID
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    
    //Show robot alert view to ask user play with robot or try again
    func ShowRobotAlert(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let alert = storyboard.instantiateViewController(withIdentifier: "RobotAlert") as! RobotAlert
        alert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        alert.imageUrl = user.image
        alert.parentController = self
        alert.robotDelegate = self
        self.present(alert, animated: true, completion: nil)
    }
}

extension BattleViewController:RobotDelegate{
    
    func playWithRobot() {
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "RobotPlayController") as! RobotPlayView
        viewCont.isCategoryBattle = self.isCategoryBattle
        viewCont.catID = self.catID
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
}
