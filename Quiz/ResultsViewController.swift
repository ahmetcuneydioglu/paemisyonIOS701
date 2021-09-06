import Foundation
import UIKit
import StoreKit

class ResultsViewController: UIViewController {
    
    @IBOutlet var lblCoin: UILabel!
    @IBOutlet var lblScore: UILabel!
    @IBOutlet var lblResults: UILabel!
    @IBOutlet var lblTrue: UILabel!
    @IBOutlet var lblFalse: UILabel!
    @IBOutlet var totalScore: UILabel!
    @IBOutlet var totalCoin: UILabel!
    @IBOutlet var nxtLvl: UIButton!
    @IBOutlet var reviewAns: UIButton!
    @IBOutlet var yourScore: UIButton!
    @IBOutlet var rateUs: UIButton!
    @IBOutlet var homeBtn: UIButton!
    @IBOutlet var viewProgress: UIView!
    @IBOutlet var view1: UIView!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet weak var resultImg: UIImageView!
    
    @IBOutlet weak var titleText: UILabel!
        
    @IBOutlet weak var backImg: UIImageView!
    
    
    var count:CGFloat = 0.0
    var progressRing: CircularProgressBar!
    var sysConfig:SystemConfiguration!
    var timer: Timer!
    
    var trueCount = 0
    var falseCount = 0
    var percentage:CGFloat = 0.0
    var earnedCoin = 0
    var earnedPoints = 0
    var ReviewQues:[ReQuestionWithE] = []
    
    var level = 0
    var catID = 0
    var questionType = "sub"
    var quesData: [QuestionWithE] = []
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var controllerName:String = ""
    var playType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 400)
        
        let xPosition = viewProgress.center.x - 20
        var yPosition = viewProgress.center.y-viewProgress.frame.origin.y + 120
        
        var progRadius:CGFloat = 38
        var minScale:CGFloat = 0.6
        var fontSize:CGFloat = 20
        
        if deviceStoryBoard == "Ipad"{
            yPosition = viewProgress.center.y-viewProgress.frame.origin.y + 150
        }
        
        if Apps.screenHeight < 750 {
            progRadius = 25
            minScale = 0.3
            fontSize = 12
            
            yPosition = viewProgress.center.y-viewProgress.frame.origin.y + 90
        }
        
        let position = CGPoint(x: xPosition, y: yPosition)
        
        // set circular progress bar here and pass required parameters
        progressRing = CircularProgressBar(radius: progRadius, position: position, innerTrackColor: Apps.defaultInnerColor, outerTrackColor: Apps.defaultOuterColor, lineWidth: 6, progValue: 100)
        viewProgress.layer.addSublayer(progressRing)
        progressRing.progressLabel.numberOfLines = 1;
        progressRing.progressLabel.font = progressRing.progressLabel.font.withSize(fontSize)
        progressRing.progressLabel.minimumScaleFactor = minScale;
        progressRing.progressLabel.textColor = UIColor.white
        progressRing.progressLabel.adjustsFontSizeToFitWidth = true;
        
        self.RegisterNotification(notificationName: "ResultView")
        self.CallNotification(notificationName: "PlayView")
        
        // Calculate the percentage of quesitons you got right
        percentage = CGFloat(trueCount) / CGFloat(Apps.TOTAL_PLAY_QS)
        percentage *= 100
        
        // set timer for progress ring and make it active
        timer = Timer.scheduledTimer(timeInterval: 0.06, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
        
        // call button design button and pass button variable those buttons need to be design
        self.DesignButton(btns: nxtLvl,reviewAns, yourScore,rateUs,homeBtn)
        
        var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
        viewProgress.SetShadow()
        
        if (self.playType == "daily") || (self.playType == "RandomQuiz") || (self.playType == "true/false"){
            titleText.text = Apps.DAILY_QUIZ_TITLE
            nxtLvl.setTitle( Apps.DAILY_QUIZ_TITLE, for: .normal)
        }
        
        func setResultLabel(){
            if (self.playType == "daily") {
                lblResults.text = Apps.DAILY_QUIZ_MSG_SUCCESS
            }else if (self.playType == "RandomQuiz") {
                lblResults.text = Apps.RANDOM_QUIZ_MSG_SUCCESS
            }else if (self.playType == "true/false"){
                lblResults.text = Apps.TF_QUIZ_MSG_SUCCESS
            }else{
                lblResults.text = Apps.COMPLETE_LEVEL
            }
        }
      
        // Based on the percentage of questions you got right present the user with different message
        if(percentage >= 30 && percentage < 50) {
            earnedCoin = 1
            setResultLabel()
            resultImg.image = UIImage(named: "trophy")
        } else if(percentage >= 50 && percentage < 70) {
            earnedCoin = 2
            setResultLabel()
            resultImg.image = UIImage(named: "trophy")
        }else if(percentage >= 70 && percentage < 90) {
            earnedCoin = 3
            setResultLabel()
            resultImg.image = UIImage(named: "trophy")
        }else if(percentage >= 90) {
            earnedCoin = 4
            setResultLabel()
            resultImg.image = UIImage(named: "trophy")
        }else{
            earnedCoin = 0
            if (self.playType == "daily") {
                lblResults.text = Apps.DAILY_QUIZ_MSG_FAIL
            }else if (self.playType == "RandomQuiz") {
                lblResults.text = Apps.RANDOM_QUIZ_MSG_FAIL
            }else if (self.playType == "true/false"){
                lblResults.text = Apps.TF_QUIZ_MSG_FAIL
            }else{
                lblResults.text = Apps.NOT_COMPLETE_LEVEL
            }
            resultImg.image = UIImage(named: "defeat")
            titleText.text = self.playType == "main" ? Apps.PLAY_AGAIN : Apps.DAILY_QUIZ_TITLE
            nxtLvl.setTitle(self.playType == "main" ? Apps.PLAY_AGAIN : Apps.DAILY_QUIZ_TITLE, for: .normal)
        }
        
        //apps has level lock unlock, remove this code if add no need level lock unlock
        if true {
            if true {
                score.coins = score.coins + earnedCoin
                if UserDefaults.standard.bool(forKey: "isLogedin") {
                    let duser =  try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
                    
                    if(Reachability.isConnectedToNetwork()){
                        self.SetUserLevel()
                        var apiURL = "user_id=\(duser.userID)&score=\(earnedPoints)"
                        self.getAPIData(apiName: "set_monthly_leaderboard", apiURL: apiURL,completion: LoadData)
                        apiURL = "user_id=\(duser.userID)&questions_answered=\(trueCount + falseCount)&correct_answers=\(trueCount)&category_id=\(catID)&ratio=\(percentage)&coins=\(score.coins)"
                        self.getAPIData(apiName: "set_users_statistics", apiURL: apiURL,completion: LoadData)
                    }else{
                        ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
                    }
                }
            }
        }
        
        lblCoin.text = "\(score.coins)"
        lblScore.text = "\(score.points)"
        
        lblTrue.text = "\(trueCount)"
        lblFalse.text = "\(Apps.TOTAL_PLAY_QS - trueCount)"
                
        totalCoin.text = "\(earnedCoin)"
        totalScore.text = "\(earnedPoints)"
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
        
        sysConfig = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    // make button custom design function
    func DesignButton(btns:UIButton...){
        for btn in btns {
            btn.SetShadow()
            btn.layer.cornerRadius = btn.frame.height / 3
        }
    }
    
    //load sub category data here
    func LoadData(jsonObj:NSDictionary){
        //print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.ShowAlert(title:Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
        }
    }
    
    
    
    // Tells the delegate the interstitial had been animated off the screen
        func adDidDismissFullScreenContent(){
        if self.controllerName == "review"{
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
            viewCont.ReviewQues = ReviewQues
            self.navigationController?.pushViewController(viewCont, animated: true)
            
        }else if self.controllerName == "home"{
            self.navigationController?.popToRootViewController(animated: true)
            
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // Note only works when time has not been invalidated yet
    @objc func resetProgressCount() {
        count = 0
        timer.fire()
    }
    
    @objc func incrementCount() {
        count += 2
        progressRing.progressManual = CGFloat(count)
        if count >= CGFloat(percentage) {
            timer.invalidate()
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func nxtButton(_ sender: UIButton) {
        //check if quiz is daily,true false or regular one first
        if self.playType == "daily" {
            DispatchQueue.main.async {
                self.ShowAlert(title: Apps.PLAYED_ALREADY, message: Apps.PLAYED_MSG)
            }
        }else{
            
            let playLevel = percentage < 30 ? self.level : self.level + 1
            self.quesData.removeAll()
            
            var apiURL = questionType == "main" ? "level=\(playLevel)&category=\(catID)" : "level=\(playLevel)&subcategory=\(catID)"
            if sysConfig.LANGUAGE_MODE == 1{
                apiURL += "&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))"
            }
         
            self.getAPIData(apiName: "get_questions_by_level", apiURL: apiURL,completion: {jsonObj in
                let status = jsonObj.value(forKey: "error") as! String
                if (status == "true") {
                    self.ShowAlert(title: Apps.OOPS, message: Apps.ERROR_MSG )
                }else{
                    //get data for category
                    if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                        for val in data{
                            self.quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", optionA: "\(val["optiona"]!)", optionB: "\(val["optionb"]!)", optionC: "\(val["optionc"]!)", optionD: "\(val["optiond"]!)", optionE: "\(val["optione"]!)", correctAns: "\(val["answer"]!)", image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)", quesType:  "\(val["question_type"]!)"))
                        }
                        Apps.TOTAL_PLAY_QS = data.count
                        //check this level has enough (10) question to play? or not
                        if self.quesData.count >= Apps.TOTAL_PLAY_QS {
                            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
                            viewCont.catID = self.catID
                            viewCont.level = playLevel
                            print("\(self.questionType) - \(self.playType)")
                            viewCont.playType = self.playType
                            viewCont.questionType = self.questionType
                            viewCont.quesData = self.quesData
                            DispatchQueue.main.async {
                                self.navigationController?.pushViewController(viewCont, animated: true)
                            }
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func reviewButton(_ sender: UIButton) {
        self.controllerName = "review"
        
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
            viewCont.ReviewQues = ReviewQues
            self.navigationController?.pushViewController(viewCont, animated: true)
        
    }
    
    @IBAction func homeButton(_ sender: UIButton) {
        self.controllerName = "home"
        
            self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    @IBAction func scoreButton(_ sender: UIButton) {
        let str  = Apps.APP_NAME
        var shareUrl = ""
        
        if self.playType == "main"{
            shareUrl = "\(Apps.SHARE1) \(self.level) \(Apps.SHARE2) \(self.earnedPoints)"
        } else if self.playType == "true/false"{
            shareUrl = "\(Apps.TF_QUIZ_SHARE_MSG) \(self.earnedPoints)"
        } else if self.playType == "RandomQuiz" {
            shareUrl = "\(Apps.RANDOM_QUIZ_SHARE_MSG) \(self.earnedPoints)"
        }else{
            shareUrl = "\(Apps.DAILY_QUIZ_SHARE_MSG) \(self.earnedPoints)"
        }
       
        let textToShare = str + "\n" + shareUrl
        //take screenshot
        UIGraphicsBeginImageContext(viewProgress.frame.size)
        viewProgress.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let vc = UIActivityViewController(activityItems: [textToShare, image! ], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = sender
        present(vc, animated: true)
    }
    
    @IBAction func rateButton(_ sender: UIButton) {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }else if let url = URL(string: Apps.SHARE_APP) {
             UIApplication.shared.open(url)
        }
    }
}

extension ResultsViewController{
    
    func SetUserLevel(){
        if(Reachability.isConnectedToNetwork()){
            let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            let apiURL = self.questionType == "main" ? "user_id=\(user.userID)&category=\(self.catID)&subcategory=0&level=\(self.level)" : "user_id=\(user.userID)&category=\(mainCatID)&subcategory=\(self.catID)&level=\(self.level)"
            self.getAPIData(apiName: "set_level_data", apiURL: apiURL,completion: { jsonObj in
               // print("JSON",jsonObj)
            })
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
}
