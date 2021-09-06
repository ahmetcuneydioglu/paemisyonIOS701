import Foundation
import UIKit
import AVFoundation
import  FirebaseDatabase
import CallKit

class RoomBattlePlayView: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var timerLabel:UILabel!
    @IBOutlet var questionView: UIView!
    @IBOutlet weak var mainQuestionLbl: UITextView!
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var mainQuesCount: UILabel!

    @IBOutlet weak var imageQuestionLbl: UITextView!
    
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var secondChildView: UIView!
    
    @IBOutlet weak var questionView1: UIView!
    
    @IBOutlet weak var battleScoreView: UIView!
    
    @IBOutlet weak var btnA: ResizableButton!
    @IBOutlet weak var btnB: ResizableButton!
    @IBOutlet weak var btnC: ResizableButton!
    @IBOutlet weak var btnD: ResizableButton!
    @IBOutlet weak var btnE: ResizableButton!
    
    @IBOutlet weak var leaveButton:UIButton!
    
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var collectionView:UICollectionView!
    
    var timer: Timer?
    
    var count: CGFloat = 0.0
    var rightCount = 0
    var wrongCount = 0
    var myAnswer = false
    var oppAnswer = false
    var oppSelectedAns = ""
    var zoomScale:CGFloat = 1
    var opponentRightCount = 0
    
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var quesData: [QuestionWithE] = []
    var currentQuestionPos = 0
    
    var joinedUsers:[JoinedUser] = []
    var user:User!
    var ref: DatabaseReference!
    var observeQues = 0
    var sysConfig:SystemConfiguration!
    var hasLeave = false
    var callObserver: CXCallObserver!
    var roomInfo:RoomDetails?
    var seconds = 0
    
    var roomType = "private"
    var roomCode = "00000"
    var isCompleted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Apps.opt_E == true {
            btnE.isHidden = false
            buttons = [btnA,btnB,btnC,btnD,btnE]
            DesignOptionButton(buttons: btnA,btnB,btnC,btnD,btnE)
        }else{
            btnE.isHidden = true
            buttons = [btnA,btnB,btnC,btnD]
            DesignOptionButton(buttons: btnA,btnB,btnC,btnD)
        }

        callObserver = CXCallObserver()
        callObserver.setDelegate(self, queue: nil) // nil queue means main thread
        
        NotificationCenter.default.post(name: Notification.Name("PlayMusic"), object: nil)
        //show 4 options by default & set 5th later by checking for opt E mode
        btnE.isHidden = true
        hasLeave = false
        buttons = [btnA,btnB,btnC,btnD]
        
        // set refrence for firebase database
        self.ref = Database.database().reference().child("MultiplayerRoom")
        mainQuestionLbl.centerVertically()
        imageQuestionLbl.centerVertically()
        
        self.seconds = Int(Apps.GROUP_BTL_WAIT_TIME)
        
        self.questionView.DesignViewWithShadow()
        
        user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        
        sysConfig = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)

            let apiURL = "room_id=\(self.roomCode)"
            self.getAPIData(apiName: "get_question_by_room_id", apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        NotificationCenter.default.addObserver(self,selector: #selector(self.CompleteBattle),name: NSNotification.Name(rawValue: "CompleteBattle"),object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        clearColor()
    }
    
    func DesignViews(battleHeight:CGFloat){
        
        let battleFrame = CGRect(x: self.battleScoreView.frame.origin.x, y: self.battleScoreView.frame.origin.y, width: self.battleScoreView.frame.width, height: battleHeight)
        self.battleScoreView.frame = battleFrame
        
        let secondFrame = CGRect(x: self.secondChildView.frame.origin.x, y: self.battleScoreView.frame.height + self.battleScoreView.frame.origin.y + 20, width: self.secondChildView.frame.width, height: self.secondChildView.frame.height)
        self.secondChildView.frame = secondFrame
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return questionImageView
    }
    
    @IBAction func settingButton(_ sender: Any) {
        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        myAlert.parentName = "play"
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func LeaveBattle(_ sender: Any) {
        let alert = UIAlertController(title: Apps.EXIT_APP_MSG,message: "",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            self.LeaveBattleProc()
           
        }))
        alert.view.tintColor = (Apps.APPEARANCE == "dark") ? UIColor.white : UIColor.black // change text color of the buttons according to respected device appearance
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
    }
    
    func LeaveBattleProc(){
        self.hasLeave = true
        let users = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        let refR = ref.child(roomCode).child("joinUser").child(users.UID)
        refR.child("isLeave").setValue("true")
       
        let roomVal = ref.child(roomCode)
        roomVal.observeSingleEvent(of: .value, with: { (snapshot) in
             if let data = snapshot.value as? [String:Any]{
               // print(data)
                let authID = data["authId"] as! String
               // print(authID)
                if authID == self.user.UID {
                    roomVal.child("isRoomActive").setValue("false")
                }
             }
        })
                
        if  let index = self.joinedUsers.firstIndex(where: {$0.uID == "\(user.UID)"}){
            self.joinedUsers[index].isLeave = true
           
            self.collectionView.reloadData()
        }
        
        if (self.timer?.isValid) != nil {
            self.timer!.invalidate()
        }
        self.ref.removeAllObservers()
     
        if(Reachability.isConnectedToNetwork()){
            let apiURL = "room_id=\(self.roomCode)" //self.roomInfo!.ID
            self.getAPIData(apiName: "destroy_room_by_room_id", apiURL: apiURL,completion: {_ in })
        }
        NotificationCenter.default.post(name: Notification.Name("StopMusic"), object: nil)
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func CompleteBattle(){
        if self.isCompleted{
            return
        }
        if timer != nil && timer!.isValid{
            timer!.invalidate()
        }
        if ref != nil{
            self.ref.removeAllObservers()
            self.ref.removeValue()
            self.ref = nil
        }
        
        if(Reachability.isConnectedToNetwork()){
            let apiURL = "room_id=\(self.roomCode)"
            self.getAPIData(apiName: "destroy_room_by_room_id", apiURL: apiURL,completion: {_ in })
        }
        showResultView()
    }
    //load sub category data here
    func LoadData(jsonObj:NSDictionary){
        let status = "\(jsonObj.value(forKey: "error")!)".bool!
        
        if (status) {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                })
            }
            
        }else{
            //get data for category
            self.quesData.removeAll()
          
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", optionA: "\(val["optiona"]!)", optionB: "\(val["optionb"]!)", optionC: "\(val["optionc"]!)", optionD: "\(val["optiond"]!)", optionE: "\(val["optione"]!)", correctAns: ("\(val["answer"]!)").lowercased(), image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)", quesType: "\(val["question_type"]!)"))
                }
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.incrementCount), userInfo: nil, repeats: true)
                self.timer!.fire()
                self.LoadQuestion()
                self.ObserveUser(self.roomCode)
            }
        });
    }
    
    func ObserveUser(_ roomcode: String){
        self.joinedUsers.removeAll()
        let refR = Database.database().reference().child("MultiplayerRoom").child(roomcode).child("joinUser")
            refR.observe(.value, with: {(snapshot) in
            print("Observe val",snapshot)
            if let data = snapshot.value as? [String:Any]{
                print("DATA",data)
                self.joinedUsers.removeAll()
                for val in data{
                    if let user = val.value as? [String:Any]{
                        self.joinedUsers.append(JoinedUser.init(uID: "\(user["UID"]!)", userID: "\(user["userID"]!)", userName: "\(user["name"]!)", userImage: "\(user["image"]!)", isJoined: "\(user["isJoined"]!)".bool ?? false,rightAns: "\(user["rightAns"] ?? "0")",wrongAns: "\(user["wrongAns"] ?? "0")",isLeave:  "\(user["isLeave"] ?? "false")".bool ?? false))
                    }
                }
                self.collectionView.reloadData()
                
                if self.joinedUsers.count == 1 || self.joinedUsers.count == 2 {
                    self.DesignViews(battleHeight: 60) //50
                }else if self.joinedUsers.count == 3 || self.joinedUsers.count == 4 {
                    self.DesignViews(battleHeight: 110) //100
                }else if self.joinedUsers.count == 5 || self.joinedUsers.count == 6 {
                    self.DesignViews(battleHeight: 160) //150
                }
                                
                let count = self.joinedUsers.filter({ $0.isLeave ?? false }).count
                if (count == self.joinedUsers.count - 1){
                    print("All User have been left")
                    if !self.hasLeave{
                        self.AllUserLeft()
                    }
                }
            }
        })
    }
    
    func AllUserLeft(){
        
        if self.isCompleted{
            return
        }        
        let alert = UIAlertController(title: "\(Apps.NO_PLYR_LEFT)",message: "",preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: Apps.OKAY, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            self.LeaveBattleProc()
           
        }))
        alert.view.tintColor = (Apps.APPEARANCE == "dark") ? UIColor.white : UIColor.black // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
    }
    
    // Note only works when time has not been invalidated yet
    @objc func resetProgressCount() {
        buttons.forEach{$0.isUserInteractionEnabled = true} 
    }
    
    @objc func incrementCount() {
        
        count += 0.1
        self.timerLabel.text = self.secondsToHoursMinutesSeconds(seconds: Int(CGFloat(CGFloat(self.seconds) - count)))
        
        if count >= CGFloat(self.seconds - 10){
        }
        if count >= CGFloat(self.seconds) {
            timer!.invalidate()
            self.SetRightWrongtoFIR()
            self.ShowResultAlert()
        }
    }
    
    //load question here
    func LoadQuestion(){
        
        if(currentQuestionPos  < quesData.count) {
            resetProgressCount()
            if(currentQuestionPos  < quesData.count && currentQuestionPos + 1 <= Apps.TOTAL_PLAY_QS ) {
                if(quesData[currentQuestionPos].image == ""){
                    mainQuestionLbl.text = quesData[currentQuestionPos].question
                    mainQuestionLbl.centerVertically()
                
                    //hide some components
                    imageQuestionLbl.isHidden = true
                    questionImageView.isHidden = true

                    mainQuestionLbl.isHidden = false
                }else{
                    imageQuestionLbl.text = quesData[currentQuestionPos].question
                    imageQuestionLbl.centerVertically()
                    questionImageView.loadImageUsingCache(withUrl: quesData[currentQuestionPos].image)

                    questionImageView.isHidden = false
                    imageQuestionLbl.isHidden = false

                    mainQuestionLbl.isHidden = true
                }
            }
            if(quesData[currentQuestionPos].optionE == "")
               {
                   Apps.opt_E = false
               }else{
                   Apps.opt_E = true
               }
               if Apps.opt_E == true {
                   clearColor(views: btnA,btnB,btnC,btnD,btnE)
                   btnE.isHidden = false
                   buttons = [btnA,btnB,btnC,btnD,btnE]
                   DesignOptionButton(buttons: btnA,btnB,btnC,btnD,btnE)
                   self.SetViewWithShadow(views: btnA,btnB, btnC, btnD, btnE)
                   // enabled options button
                   MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD,btnE)
               }else{
                clearColor(views: btnA,btnB,btnC,btnD)
                   btnE.isHidden = true
                   buttons = [btnA,btnB,btnC,btnD]
                   DesignOptionButton(buttons: btnA,btnB,btnC,btnD)
                   self.SetViewWithShadow(views: btnA,btnB, btnC, btnD)
                   // enabled options button
                   MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD)
               }
            self.SetButtonOption(options: quesData[currentQuestionPos].optionA,quesData[currentQuestionPos].optionB,quesData[currentQuestionPos].optionC,quesData[currentQuestionPos].optionD,quesData[currentQuestionPos].optionE,quesData[currentQuestionPos].correctAns)
            
            mainQuesCount.roundCorners(corners: [.topLeft,.topRight,.bottomLeft,.bottomRight], radius: 5)
            mainQuesCount.text = "\(currentQuestionPos + 1) / \(Apps.TOTAL_PLAY_QS)"
            
        } else {
            // If there are no more questions show the results
            if oppAnswer{
                ShowResultAlert()
            }
            self.scroll.setContentOffset(.zero, animated: true)
            
            self.secondChildView.isHidden = true
            
            self.btnA.isHidden = true
            self.btnB.isHidden = true
            self.btnC.isHidden = true
            self.btnD.isHidden = true
            self.btnE.isHidden = true
            
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: self.scroll.frame.width, height: self.scroll.frame.height))
            noDataLabel.text          = Apps.BTL_WAIT_MSG
            noDataLabel.textColor     = Apps.BASIC_COLOR
            noDataLabel.textAlignment = .center
            noDataLabel.numberOfLines = 0
            noDataLabel.font = noDataLabel.font?.withSize(deviceStoryBoard == "Ipad" ? 25 : 15)
            noDataLabel.lineBreakMode = .byWordWrapping
            
            self.scroll.addSubview(noDataLabel)
        }
    }
    
    var btnY = 0
    func SetButtonHeight(buttons:UIButton...){
        
        self.scroll.setContentOffset(.zero, animated: true)
        self.scroll.contentSize = CGSize(width: self.scroll.frame.width, height: self.view.frame.height)
        
        btnY = Int(self.secondChildView.frame.height + self.secondChildView.frame.origin.y + 20)
        
        for button in buttons{
            let btnWidth = self.btnD.frame.width
            
            let btnX = button.frame.origin.x
            
            let size = button.intrinsicContentSize
            let newHeight = size.height > 50 ? size.height : 50
            let newFram = CGRect(x: Int(btnX), y: btnY, width: Int(btnWidth), height: Int(newHeight))
            btnY += Int(newHeight) + 10
            button.frame = newFram
            
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.layoutIfNeeded()
            button.layoutIfNeeded()
        }
        
        let with = self.scroll.frame.width
        self.scroll.contentSize = CGSize(width: Int(with), height: Int(btnY + 10))
    }
    
    func ShowResultAlert(){
        
        NotificationCenter.default.post(name: Notification.Name("StopMusic"), object: nil)
        if timer != nil && timer!.isValid{
            timer!.invalidate()
        }
        
       showResultView()
    }
    func showResultView(){
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "BattleRoomResult") as! BattleRoomResult
        viewCont.joinedUsers = self.joinedUsers
        viewCont.roomType = self.roomType
        viewCont.roomInfo = self.roomInfo
        viewCont.roomCode = self.roomCode
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    
    // right answer operation function
    func rightAnswer(btn:UIView){
        
        //score count
        rightCount += 1
        self.ref.child(user.UID).child("rightAns").setValue("\(rightCount)")
        
        btn.backgroundColor = Apps.RIGHT_ANS_COLOR
        btn.tintColor = UIColor.white
        
        // sound
        self.PlaySound(player: &audioPlayer, file: "right")

        self.SetRightWrongtoFIR()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
            DispatchQueue.main.async {
                self.currentQuestionPos += 1 //increment for next question
                self.LoadQuestion()
            }
        });
    }
    // wrong answer operation function
    func wrongAnswer(btn:UIView?){
        
        for rbtn in self.buttons{
            if rbtn.tag == 1{
                rbtn.backgroundColor = Apps.RIGHT_ANS_COLOR
                rbtn.tintColor = UIColor.white
            }
        }
        //score count
        wrongCount += 1
        
        btn?.backgroundColor = Apps.WRONG_ANS_COLOR
        btn?.tintColor = UIColor.white
        
        // sound
        self.PlaySound(player: &audioPlayer, file: "wrong")
        
        self.SetRightWrongtoFIR()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
            DispatchQueue.main.async {
                self.currentQuestionPos += 1 //increment for next question
                self.LoadQuestion()
            }
        });
    }
    
    //observe data in firebase and show updated data to user
    func SetRightWrongtoFIR(){
        
        let users = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        let refR = ref.child(roomCode).child("joinUser").child(users.UID)
        
        refR.child("rightAns").setValue("\(self.rightCount)")
        refR.child("wrongAns").setValue("\(self.wrongCount)")
    }
    
    // set button option's
    var buttons:[UIButton] = []
    func SetButtonOption(options:String...){
        clickedButton.removeAll()
        var temp : [String]
        if Apps.opt_E == true {
            temp = ["a","b","c","d","e"]
            self.buttons = [btnA,btnB,btnC,btnD,btnE]
        }else{
            temp = ["a","b","c","d"]
            self.buttons = [btnA,btnB,btnC,btnD]
        }
        var i = 0
        for button in buttons{
            button.setImage(SetClickedOptionView(otpStr: temp[i]).createImage(), for: .normal)
            i += 1
        }  
        let singleQues = quesData[currentQuestionPos]
        if singleQues.quesType == "2"{
            clearColor(views: btnA,btnB)
            MakeChoiceBtnDefault(btns: btnA,btnB)
            self.buttons = [btnA,btnB]
    
            btnC.isHidden = true
            btnD.isHidden = true
            btnE.isHidden = true
         
            temp = ["a","b"]
            
        }else{
                       
            if Apps.opt_E == true {
            self.buttons = [btnA,btnB,btnC,btnD,btnE]
                clearColor(views: btnA,btnB,btnC,btnD,btnE)
                MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD,btnE)
                btnE.isHidden = false
            }else{
                self.buttons = [btnA,btnB,btnC,btnD]
                clearColor(views: btnA,btnB,btnC,btnD)
                MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD)
            }
            btnC.isHidden = false
            btnD.isHidden = false
                        
            buttons.shuffle()
        }
        
        let ans = temp
        var rightAns = ""
        if ans.contains("\(options.last!.lowercased())") {
            rightAns = options[ans.firstIndex(of: options.last!.lowercased())!]
        }else{
            rightAnswer(btn: btnA)
        }
        buttons.shuffle()
        var index = 0
        for button in buttons{
            button.titleLabel?.lineBreakMode = .byCharWrapping
            button.setTitle(options[index].trimmingCharacters(in: .whitespaces), for: .normal)
            if options[index] == rightAns{
                button.tag = 1
            }else{
                button.tag = 0
            }
            button.addTarget(self, action: #selector(ClickButton), for: .touchUpInside)
            button.addTarget(self, action: #selector(ButtonDown), for: .touchDown)
            index += 1
        }
        self.SetButtonHeight(buttons: btnA,btnB,btnC,btnD,btnE)
    }
    func clearColor(views:UIView...){
        for view in views{
            view.isHidden = false
            view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            view.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true) 
        }
    }
    // option buttons click action
    @objc func ClickButton(button:UIButton){
        if clickedButton.first?.title(for: .normal) == button.title(for: .normal){
            buttons.forEach{$0.isUserInteractionEnabled = false}
            if button.tag == 1{
                rightAnswer(btn: button)
            }else{
                wrongAnswer(btn: button)
            }
        }else{
            clickedButton.removeAll()
            buttons.forEach{$0.isUserInteractionEnabled = true}
        }
    }
    
    var clickedButton:[UIButton] = []
    @objc func ButtonDown(button:UIButton){
        clickedButton.append(button)
    }
    // set default to four/five choice button
    func MakeChoiceBtnDefault(btns:UIButton...){
        for btn in btns {
            btn.isEnabled = true
            btn.isHidden = false
            btn.frame = self.btnA.frame
            btn.layer.backgroundColor =  UIColor.white.withAlphaComponent(0.8).cgColor
            btn.subviews.forEach({
                if($0.tag == 11){
                    $0.removeFromSuperview()
                }
            })
        }
    }
}

class ResizableButton: UIButton {
    override var intrinsicContentSize: CGSize {
       let labelSize = titleLabel?.sizeThatFits(CGSize(width: frame.width, height: .greatestFiniteMagnitude)) ?? .zero
       let desiredButtonSize = CGSize(width: labelSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: labelSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom + 25)

       return desiredButtonSize
    }
}

extension RoomBattlePlayView: CXCallObserverDelegate {
        
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded == true {
            print("Disconnected")
        }
        
        if call.isOutgoing == true && call.hasConnected == false {
            print("Dialing")
        }
        
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            print("Incoming")
        }
        
        if call.hasConnected == true && call.hasEnded == false {
            print("Connected")
            self.LeaveBattleProc()
        }
    }
}
