import Foundation
import UIKit
import StoreKit

class ContestResultsViewController: UIViewController {
    
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
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var resultImg: UIImageView!
    
    
    var count:CGFloat = 0.0
    var progressRing: CircularProgressBar!
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
    var contestID = 0
    var quesData: [QuestionWithE] = []
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var controllerName:String = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 400)
        
        // set circular progress bar here and pass required parameters
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
       // view1.SetShadow()
        viewProgress.SetShadow()
        // Based on the percentage of questions you got right present the user with different message
        if(percentage >= 30 && percentage < 50) {
            earnedCoin = 1
            lblResults.text = Apps.COMPLETE_LEVEL
            resultImg.image = UIImage(named: "trophy")
        } else if(percentage >= 50 && percentage < 70) {
            earnedCoin = 2
            lblResults.text = Apps.COMPLETE_LEVEL
            resultImg.image = UIImage(named: "trophy")
        }else if(percentage >= 70 && percentage < 90) {
            earnedCoin = 3
            lblResults.text = Apps.COMPLETE_LEVEL
            resultImg.image = UIImage(named: "trophy")
        }else if(percentage >= 90) {
            earnedCoin = 4
            lblResults.text = Apps.COMPLETE_LEVEL
            resultImg.image = UIImage(named: "trophy")
        }else{
            earnedCoin = 0
            lblResults.text = Apps.NOT_COMPLETE_LEVEL
            resultImg.image = UIImage(named: "defeat")
            titleText.text = Apps.PLAY_AGAIN
            nxtLvl.setTitle(Apps.PLAY_AGAIN, for: .normal)
        }
        
        score.points = score.points + earnedPoints
        score.coins = score.coins + earnedCoin
        
        totalCoin.text = "\(score.coins)"
        totalScore.text = "\(score.points)"
        
        if UserDefaults.standard.bool(forKey: "isLogedin") {
            let duser =  try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            if(Reachability.isConnectedToNetwork()){
                let apiURL = "user_id=\(duser.userID)&contest_id=\(contestID)&questions_attended=\(trueCount + falseCount)&correct_answers=\(trueCount)&score=\(earnedPoints)"
                self.getAPIData(apiName: "contest_update_score", apiURL: apiURL,completion: LoadData)
            }else{
                ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
            }
        }
        score.coins = score.coins + earnedCoin
        
        lblCoin.text = "\(score.coins)"
        lblScore.text = "\(score.points)"
        
        lblTrue.text = "\(trueCount)"
        lblFalse.text = "\(Apps.TOTAL_PLAY_QS - trueCount)"
                
        totalCoin.text = "\(earnedCoin)"
        totalScore.text = "\(earnedPoints)"
            
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
        print("RS",jsonObj)
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
    
    // Note: only works when time has not been invalidated yet
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
        let shareUrl = "\(Apps.SHARE_CONTEST) \(self.earnedPoints)"
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
