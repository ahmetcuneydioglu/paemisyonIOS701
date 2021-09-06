import Foundation
import UIKit
import AVFoundation

class SelfPlayResultView: UIViewController {
    
    @IBOutlet var timerLabel: UILabel!
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
    
    
    var count:CGFloat = 0.0
    var progressRing: CircularProgressBar!
    var timer: Timer!
    
    var trueCount = 0
    var falseCount = 0
    var percentage:CGFloat = 0.0
    
    var ReviewQues:[ReQuestionWithE] = []
    var quesCount = 0
    var quesData: [QuestionWithE] = []
    
    var completedTime = 0
    var totalTime = 0
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var controllerName:String = ""
    var audioPlayer : AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 430)
        
        var xPosition = viewProgress.center.x - 20
        var yPosition = viewProgress.center.y-viewProgress.frame.origin.y - 15
        
        var progRadius:CGFloat = 35
        var minScale:CGFloat = 0.5
        var fontSize:CGFloat = 20
        // set circular progress bar here and pass required parameters
        if Apps.screenHeight < 750 {
            progRadius = 25
            minScale = 0.3
            fontSize = 12
            
            xPosition = viewProgress.center.x - 20
            yPosition = viewProgress.center.y-viewProgress.frame.origin.y
        }
        
        let position = CGPoint(x: xPosition, y: yPosition)
        
        progressRing = CircularProgressBar(radius: progRadius, position: position, innerTrackColor: Apps.defaultInnerColor, outerTrackColor: Apps.defaultOuterColor, lineWidth: 5,progValue: CGFloat(self.totalTime))
        viewProgress.layer.addSublayer(progressRing)
        progressRing.progressLabel.numberOfLines = 1;
        progressRing.progressLabel.font = progressRing.progressLabel.font.withSize(fontSize)
        progressRing.progressLabel.minimumScaleFactor = minScale;
        progressRing.progressLabel.textColor = UIColor.white
        progressRing.progressLabel.adjustsFontSizeToFitWidth = true;
        
        self.lblResults.text = "\(Apps.RESULT_TXT) \(self.secondsToHoursMinutesSeconds(seconds: (self.totalTime - self.completedTime))) \(Apps.SECONDS)"
        // Calculate the percentage of questions you got right here
        self.timerLabel.text = "\(Apps.CHLNG_TIME) \(self.secondsToHoursMinutesSeconds(seconds: self.totalTime))"
        
        var attempCount = 0
        for rev in self.ReviewQues{
            let rightStr = self.GetRightAnsString(correctAns: rev.correctAns, quetions: rev)
            if rightStr == rev.userSelect{
                self.trueCount += 1
            }
            
            if rev.userSelect != ""{
                attempCount += 1
            }
        }
        percentage = CGFloat(trueCount) / CGFloat(attempCount)
        percentage *= 100
        // set timer for progress ring and make it active
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
        
        // call button design button and pass button variable those buttons need to be design
        self.DesignButton(btns: nxtLvl,reviewAns, yourScore,rateUs,homeBtn)
        
        viewProgress.SetShadow()
        
        lblTrue.text = "\(trueCount)"
        lblFalse.text = "\(attempCount - trueCount)"
        
        
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
            self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
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
        let comTime = self.totalTime - self.completedTime
        count += 1
        progressRing.progressManual = CGFloat(count)
        progressRing.progressLabel.text = self.secondsToHoursMinutesSeconds(seconds: Int(count))
        if count >= CGFloat(comTime) {
            timer.invalidate()
            return
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func nxtButton(_ sender: UIButton) {
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "categoryview")
        self.navigationController?.pushViewController(viewCont, animated: true)
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
        let shareUrl = "\(Apps.SELF_CHALLENGE_SHARE1) \(self.secondsToHoursMinutesSeconds(seconds: Int(self.totalTime))) \(Apps.SELF_CHALLENGE_SHARE2) \(self.secondsToHoursMinutesSeconds(seconds: (self.totalTime - self.completedTime))) \(Apps.SELF_CHALLENGE_SHARE3)"
        let textToShare = str + "\n" + shareUrl
        let vc = UIActivityViewController(activityItems: [textToShare], applicationActivities: [])
         vc.popoverPresentationController?.sourceView = sender
        present(vc, animated: true)
    }
        
    func GetRightAnsString(correctAns:String, quetions:ReQuestionWithE)->String{
        if correctAns == "a"{
            return quetions.optionA
        }else if correctAns == "b"{
            return quetions.optionB
        }else if correctAns == "c"{
            return quetions.optionC
        }else if correctAns == "d"{
            return quetions.optionD
        }else if correctAns == "e"{
            return quetions.optionE
        }else{
            return ""
        }
    }
    
    @IBAction func rateButton(_ sender: UIButton) {
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "BattleViewController")
            self.navigationController?.pushViewController(viewCont, animated: true)
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
