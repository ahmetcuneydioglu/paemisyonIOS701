import Foundation
import UIKit
import AVFoundation

class PlayQuizView: UIViewController, UIScrollViewDelegate {
    
    let progressBar = UIProgressView.Vertical(color: UIColor.Vertical_progress_true)
    let progressFalseBar = UIProgressView.Vertical(color: UIColor.Vertical_progress_false)
    
    @IBOutlet weak var titleBar: UILabel!
    @IBOutlet var lblQuestion: UITextView!
    @IBOutlet var question: UITextView!
    
    @IBOutlet var btnA: UIButton!
    @IBOutlet var btnB: UIButton!
    @IBOutlet var btnC: UIButton!
    @IBOutlet var btnD: UIButton!
    @IBOutlet var btnE: UIButton!
        
    @IBOutlet weak var bookmarkBtn: UIButton!
    @IBOutlet var secondChildView: UIView!
    
    @IBOutlet weak var lifeLineView: UIView!
        
    @IBOutlet weak var questionImage: UIImageView!
    @IBOutlet var mainQuestionView: UIView!
    @IBOutlet var speakBtn: UIButton!
    @IBOutlet var zoomBtn: UIButton!
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var zoomScroll: UIScrollView!
    
    @IBOutlet var scoreLbl: UILabel!
    @IBOutlet var trueLbl: UILabel!
    @IBOutlet var falseLbl: UILabel!
    
    @IBOutlet var view1: UIView!
    @IBOutlet weak var progFalseView: UIView!
    @IBOutlet weak var questionView: UIView!
        
    var count: CGFloat = 0.0
    var score: Int = 0
    
    var progressRing: CircularProgressBar!
    var timer: Timer!
    var player: AVAudioPlayer?
        
    
    var falseCount = 0
    var trueCount = 0
    
    @IBOutlet weak var mainQuesCount: UILabel!
    @IBOutlet weak var mainScoreCount: UILabel!
    @IBOutlet weak var mainCoinCount: UILabel!
    
    @IBOutlet weak var proview: UIView!
    @IBOutlet var verticalView: UIView!
    
    var jsonObj : NSDictionary = NSDictionary()
    var quesData: [QuestionWithE] = []
    var reviewQues:[ReQuestionWithE] = []
    var BookQuesList:[QuestionWithE] = []
    
    var currentQuestionPos = 0
   
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var level = 0
    var catID = 0
    var questionType = "sub"
    var titlebartext = ""
    var zoomScale:CGFloat = 1
    
    var opt_ft = false
    var opt_sk = false
    var opt_au = false
    var opt_re = false
    
    var correctAnswer = "a"
    
    var callLifeLine = ""
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var playType = ""
    
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
    
        //font
        resizeTextview()
      
        //get bookmark list
        if (UserDefaults.standard.value(forKey: "booklist") != nil){
            BookQuesList = try! PropertyListDecoder().decode([QuestionWithE].self, from:((UserDefaults.standard.value(forKey: "booklist") as? Data)!))
                print(BookQuesList)
        }
        
        self.RegisterNotification(notificationName: "PlayView")
        self.CallNotification(notificationName: "ResultView")
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayQuizView.ReloadFont), name: NSNotification.Name(rawValue: "ReloadFont"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayQuizView.ResumeTimer), name: NSNotification.Name(rawValue: "ResumeTimer"), object: nil)
        
        setVerticleProgress(view: proview, progress: progressBar)// true progres bar
        setVerticleProgress(view: progFalseView, progress: progressFalseBar)// false progress bar
        
        let mScore = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
        mainScoreCount.text = "\(mScore.points)"
        mainCoinCount.text = "\(mScore.coins)"

        zoomScroll.minimumZoomScale = 1.0
        zoomScroll.maximumZoomScale = 6.0
        
        self.questionView.DesignViewWithShadow()
        
        let xPosition = view1.center.x - 10
        let yPosition = view1.center.y - 5 //+ 1 //- 5
        let position = CGPoint(x: xPosition, y: yPosition)
        progressRing = CircularProgressBar(radius: (view1.frame.size.height - 20) / 2, position: position, innerTrackColor: Apps.defaultInnerColor, outerTrackColor: Apps.defaultOuterColor, lineWidth: 6)
        view1.layer.addSublayer(progressRing)
        
        quesData.shuffle()
        
                
        switch (self.playType){
        case "daily" :
            self.titleBar.text = Apps.DAILY_QUIZ
            break
        case "RandomQuiz" :
            self.titleBar.text = "Random Quiz"
            break
        case "true/false" :
            self.titleBar.text = "True/False"
            break
        default: //for "main" & "sub" values
            self.titleBar.text = "\(Apps.LEVEL) \(level)"
            break
        }
        self.loadQuestion()
    }
    
    
    @objc func ReloadFont(noti: NSNotification){
        resizeTextview()
    }
    
    

         
    
    func resizeTextview(){
        
        var getFont = UserDefaults.standard.float(forKey: "fontSize")
        if (getFont == 0){
            getFont = (deviceStoryBoard == "Ipad") ? 26 : 16
        }
        lblQuestion.font = lblQuestion.font?.withSize(CGFloat(getFont))
        question.font = question.font?.withSize(CGFloat(getFont))
        
        lblQuestion.centerVertically()
        question.centerVertically()
        
        btnA.titleLabel?.font = btnA.titleLabel?.font?.withSize(CGFloat(getFont))
        btnB.titleLabel?.font = btnB.titleLabel?.font?.withSize(CGFloat(getFont))
        btnC.titleLabel?.font = btnC.titleLabel?.font?.withSize(CGFloat(getFont))
        btnD.titleLabel?.font = btnD.titleLabel?.font?.withSize(CGFloat(getFont))
        btnE.titleLabel?.font = btnE.titleLabel?.font?.withSize(CGFloat(getFont))
        
        btnA.resizeButton()
        btnB.resizeButton()
        btnC.resizeButton()
        btnD.resizeButton()
        btnE.resizeButton()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return questionImage
    }

    // resume timer when setting alert closed
    @objc func ResumeTimer(){
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    // Note only works when time has not been invalidated yet
    @objc func resetProgressCount() {
       buttons.forEach{$0.isUserInteractionEnabled = true}
        if self.timer != nil && self.timer.isValid{
            self.timer.invalidate()
        }
        progressRing.innerTrackShapeLayer.strokeColor = Apps.defaultInnerColor.cgColor
        progressRing.progressLabel.textColor = Apps.BASIC_COLOR
        zoomScale = 1
        zoomScroll.zoomScale = 1
        count = 0
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    @objc func incrementCount() {
        count += 0.1
        progressRing.progress = CGFloat(Apps.QUIZ_PLAY_TIME - count)
        if count >= 20{
              progressRing.innerTrackShapeLayer.strokeColor = Apps.WRONG_ANS_COLOR.cgColor
              progressRing.progressLabel.textColor = Apps.WRONG_ANS_COLOR
        }
        if count >= Apps.QUIZ_PLAY_TIME { // set timer here
            
            timer.invalidate()
            currentQuestionPos += 1
            //mark it as wrong answer if user haven't selected any option from given 4/5 or 2 option
            falseCount += 1
            falseLbl.text = "\(falseCount)"
            progressFalseBar.setProgress(Float(falseCount) / Float(Apps.TOTAL_PLAY_QS), animated: true)
            
            var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
            score.points = score.points - Apps.QUIZ_W_Q_POINTS
            UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
            
            self.PlaySound(player: &audioPlayer, file: "wrong")
              loadQuestion()
      }
    }
    
    @IBAction func settingButton(_ sender: Any) {
        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        myAlert.isPlayView = true
        self.present(myAlert, animated: true, completion: {
             self.timer.invalidate()
        })
    }
    
    @IBAction func backButton(_ sender: Any) {
        let alert = UIAlertController(title: Apps.EXIT_PLAY,message: "",preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))

        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            self.timer.invalidate()
            self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary(rawValue: 0)!)
            self.navigationController?.popViewController(animated: true)
        }))
        
        alert.view.tintColor = (Apps.APPEARANCE == "dark") ? UIColor.white : UIColor.black // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func speakButton(_ sender: Any) {
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: "\(quesData[currentQuestionPos].question)")
        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
        speechUtterance.voice = AVSpeechSynthesisVoice(language: Apps.LANG)
        speechSynthesizer.speak(speechUtterance)
    }
    
    @IBAction func zoomBtn(_ sender: Any) {
        if zoomScroll.zoomScale == zoomScroll.maximumZoomScale {
                   zoomScale = 0
               }
        zoomScale += 1
        zoomScroll.zoomScale = zoomScale
    }
    
    //50 50 option select
    @IBAction func fiftyButton(_ sender: Any) {
        if(!opt_ft){
             var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
            
            if(score.coins < Apps.OPT_FT_COIN){
                // user does not have enough coins
                self.ShowAlertForNotEnoughCoins(requiredCoins: Apps.OPT_FT_COIN, lifelineName: "fifty")
            }else{
                // if user have coins
                var index = 0
                for button in buttons{
                          if button.tag == 0 && index < 2 { //To remove 3 options from 5, use 3 instead of 2 here
                          button.isHidden = true
                          index += 1
                      }
                }
                opt_ft = true
                //deduct coin for use lifeline and store it
                 score.coins = score.coins - Apps.OPT_FT_COIN
                 UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
                 mainCoinCount.text = "\(score.coins)"
            }
        }else{
            self.ShowAlert(title: Apps.LIFELINE_ALREDY_USED_TITLE, message: Apps.LIFELINE_ALREDY_USED)
        }
    }
    
    //skip option select
    @IBAction func SkipBtn(_ sender: Any) {
        if(!opt_sk){
            var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
            
            if(score.coins < Apps.OPT_SK_COIN){
                // user dose not have enough coins
                self.ShowAlertForNotEnoughCoins(requiredCoins: Apps.OPT_SK_COIN, lifelineName: "skip")
            }else{
                // if user have coins
                timer.invalidate()
                currentQuestionPos += 1
                loadQuestion()
                
                opt_sk = true
                //deduct coin for use lifeline and store it
                score.coins = score.coins - Apps.OPT_SK_COIN
                UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
                 mainCoinCount.text = "\(score.coins)"
            }
        }else{
            self.ShowAlert(title: Apps.LIFELINE_ALREDY_USED_TITLE, message: Apps.LIFELINE_ALREDY_USED)
        }
    }
    
    //Audios poll option select
    @IBAction func AudionsBtn(_ sender: Any) {
        if(!opt_au){
            var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
            
            if(score.coins < Apps.OPT_SK_COIN){
                // user dose not have enough coins
                self.ShowAlertForNotEnoughCoins(requiredCoins: Apps.OPT_AU_COIN, lifelineName: "audions")
            }else{
                // if user have coins
                var r1:Int,r2:Int,r3:Int,r4:Int,r5:Int
                
                r1 = Int.random(in: 1 ... 96)
                r2 = Int.random(in: 1 ... 97 - r1)
                r3 = Int.random(in: 1 ... 98 - r1 - r2)
                r5 = Int.random(in: 1 ... 98 - r1 - r2 - r3)
                r4 = 100 - r1 - r2 - r3 - r5
                
                var randoms = [r1,r2,r3,r5,r4]
                randoms.sort(){$0 > $1}
                
                var index = 0
                for button in buttons{
                    if button.tag == 1{
                        drawCircle(btn: button, proVal: randoms[0])
                    }else{
                        index += 1
                        drawCircle(btn: button, proVal: randoms[index])
                    }
                }
                opt_au = true
        
                //deduct coin for use lifeline and store it
                score.coins = score.coins - Apps.OPT_AU_COIN
                UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
                mainCoinCount.text = "\(score.coins)"
            }
        }else{
            self.ShowAlert(title: Apps.LIFELINE_ALREDY_USED_TITLE, message: Apps.LIFELINE_ALREDY_USED)
        }
    }
    
    //reset timer option select
    @IBAction func ResetBtn(_ sender: Any) {
        if(!opt_re){
            var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
            
            if(score.coins < Apps.OPT_RES_COIN){
                // user dose not have enough coins
                self.ShowAlertForNotEnoughCoins(requiredCoins: Apps.OPT_RES_COIN, lifelineName: "reset")
            }else{
                // if user have coins
                timer.invalidate()
                resetProgressCount()
                opt_re = true
                //deduct coin for use lifeline and store it
                score.coins = score.coins - Apps.OPT_RES_COIN
                UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
                mainCoinCount.text = "\(score.coins)"
            }
        }else{
            self.ShowAlert(title: Apps.LIFELINE_ALREDY_USED_TITLE, message: Apps.LIFELINE_ALREDY_USED)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        clearColor()
    }
    
    @IBAction func BookMark(_ sender: Any) {
        
        if(self.bookmarkBtn.tag == 0){
            let reQues = quesData[currentQuestionPos]
            self.BookQuesList.append(QuestionWithE.init(id: reQues.id, question: reQues.question, optionA: reQues.optionA, optionB: reQues.optionB, optionC: reQues.optionC, optionD: reQues.optionD, optionE: reQues.optionE, correctAns: reQues.correctAns, image: reQues.image, level: reQues.level, note: reQues.note, quesType: reQues.quesType))
            bookmarkBtn.setBackgroundImage(UIImage(named: "book-on"), for: .normal)
            bookmarkBtn.tag = 1
            self.SetBookmark(quesID: reQues.id, status: "1", completion: {})
        }else{
            BookQuesList.removeAll(where: {$0.id == quesData[currentQuestionPos].id && $0.correctAns == quesData[currentQuestionPos].correctAns})
            bookmarkBtn.setBackgroundImage(UIImage(named: "book-off"), for: .normal)
            bookmarkBtn.tag = 0
            let reQues = quesData[currentQuestionPos]
            self.SetBookmark(quesID: reQues.id, status: "0", completion: {})
        }
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(BookQuesList), forKey: "booklist")
        
    }
    // right answer operation function
    func rightAnswer(btn:UIView){
        
        //make timer invalidate
        timer.invalidate()
        
        //score count
        trueCount += 1
        trueLbl.text = "\(trueCount)"
        progressBar.setProgress(Float(trueCount) / Float(Apps.TOTAL_PLAY_QS), animated: true)
        
        var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
        score.points = score.points + Apps.QUIZ_R_Q_POINTS
        UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
        
        btn.backgroundColor = Apps.RIGHT_ANS_COLOR
        btn.tintColor = UIColor.white
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.3
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: btn.center.x, y: btn.center.y - 5))
        animation.toValue = NSValue(cgPoint: CGPoint(x: btn.center.x, y: btn.center.y + 5))
        btn.layer.add(animation, forKey: "position")
        
        // sound
        self.PlaySound(player: &audioPlayer, file: "right")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            // load next question after 1 second
            self.currentQuestionPos += 1 //increment for next question
            self.loadQuestion()
        })
    }
    
    // wrong answer operation function
    func wrongAnswer(btn:UIView?){
        //make timer invalidate
        timer.invalidate()
        
        //score count
        falseCount += 1
        falseLbl.text = "\(falseCount)"
        progressFalseBar.setProgress(Float(falseCount) / Float(Apps.TOTAL_PLAY_QS), animated: true)
        
        var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
        score.points = score.points - Apps.QUIZ_W_Q_POINTS
        UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
        
        btn?.backgroundColor = Apps.WRONG_ANS_COLOR
        btn?.tintColor = UIColor.white
        
        if Apps.ANS_MODE == "1"{
            //show correct answer
            for button in buttons{
                if button.titleLabel?.text == correctAnswer{
                     button.tag = 1
                }
                for button in buttons {
                    if button.tag == 1{
                        button.backgroundColor = Apps.RIGHT_ANS_COLOR
                        button.tintColor = UIColor.white
                        break
                    }
                }
            }
        }
        
        // sound
        self.PlaySound(player: &audioPlayer, file: "wrong")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            // load next question after 1 second
            self.currentQuestionPos += 1 //increment for next question
            self.loadQuestion()
        })
    }
    
    func clearColor(views:UIView...){
        for view in views{
            view.isHidden = false
            view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            view.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
        }
    }
    
    // set question vcalue and its answer here
    @objc func loadQuestion() {
        // Show next question
        
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary(rawValue: 0)!)
        resetProgressCount() // reset timer
            
        if(currentQuestionPos  < quesData.count && currentQuestionPos + 1 <= Apps.TOTAL_PLAY_QS ) {
           
            if(quesData[currentQuestionPos].image == ""){
                // if question dose not contain images
                question.text = quesData[currentQuestionPos].question
                question.centerVertically()
                //hide some components
                lblQuestion.isHidden = true
                questionImage.isHidden = true
                zoomBtn.isHidden = true
                
                question.isHidden = false
            }else{
                // if question has image
                lblQuestion.text = quesData[currentQuestionPos].question
                lblQuestion.centerVertically()
                questionImage.loadImageUsingCache(withUrl: quesData[currentQuestionPos].image)
                //show some components
                lblQuestion.isHidden = false
                questionImage.isHidden = false
                zoomBtn.isHidden = false
                question.isHidden = true
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
            
            mainQuesCount.roundCorners(corners: [.topLeft,.topRight,.bottomRight,.bottomLeft], radius: 5)
            mainQuesCount.text = "\(currentQuestionPos + 1) / \(Apps.TOTAL_PLAY_QS)"
            mainScoreCount.text = "\((trueCount * Apps.QUIZ_R_Q_POINTS) - (falseCount * Apps.QUIZ_W_Q_POINTS))"
            
            //check current question is in bookmark list or not
            if(BookQuesList.contains(where: {$0.id == quesData[currentQuestionPos].id && $0.correctAns == quesData[currentQuestionPos].correctAns})){
                self.bookmarkBtn.setBackgroundImage(UIImage(named: "book-on"), for: .normal)
                self.bookmarkBtn.tag = 1
            }else{
                self.bookmarkBtn.setBackgroundImage(UIImage(named: "book-off"), for: .normal)
                self.bookmarkBtn.tag = 0
            }
        } else {
            self.ShowResultView()
        }
    }
    
    
    func ShowResultView(){
        timer.invalidate()
        // If there are no more questions show the results
        let resultView:ResultsViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
        resultView.playType = self.playType
        
        resultView.trueCount = trueCount
        resultView.falseCount = falseCount
        resultView.earnedPoints = (trueCount * Apps.QUIZ_R_Q_POINTS) - (falseCount * Apps.QUIZ_W_Q_POINTS)
        resultView.ReviewQues = reviewQues
        resultView.level = self.level
        resultView.catID = self.catID
        resultView.questionType = self.questionType
        self.navigationController?.pushViewController(resultView, animated: true)
    }
    var btnY = 0
      func SetButtonHeight(buttons:UIButton...){
          
          var minHeight = 50
          if UIDevice.current.userInterfaceIdiom == .pad{
              minHeight = 90
          }else{
              minHeight = 50
          }
          self.scroll.setContentOffset(.zero, animated: true)
          
          let perButtonChar = 35
          btnY = Int(self.secondChildView.frame.height + self.secondChildView.frame.origin.y + 10)
          for button in buttons{
              let btnWidth = button.frame.width
              //let fonSize = 18
              let charCount = button.title(for: .normal)?.count
              
              let btnX = button.frame.origin.x
              
              let charLine = Int(charCount! / perButtonChar) + 1
              
              let btnHeight = charLine * 20 < minHeight ? minHeight : charLine * 20
              
              let newFram = CGRect(x: Int(btnX), y: btnY, width: Int(btnWidth), height: btnHeight)
              btnY += btnHeight + 8
              
              button.frame = newFram
              
              button.titleLabel?.lineBreakMode = .byWordWrapping
              button.titleLabel?.numberOfLines = 0
          }
          let with = self.scroll.frame.width
          self.scroll.contentSize = CGSize(width: Int(with), height: Int(btnY))
      }
    
    // set button option's
    var buttons:[UIButton] = []
    func SetButtonOption(options:String...){
        clickedButton.removeAll()
        var temp : [String]        
        if options.contains("") {
           print("true - \(options)")
           temp = ["a","b","c","d"]
           self.buttons = [btnA,btnB,btnC,btnD]
       }else{
             print("false - \(options)")
             temp = ["a","b","c","d","e"]
             self.buttons = [btnA,btnB,btnC,btnD,btnE]
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
            
            btnC.isHidden = true
            btnD.isHidden = true

            self.buttons = [btnA,btnB]
             temp = ["a","b"]
            //lifelines are not applicable for true/ false
            lifeLineView.alpha = 0
        }else{
            btnC.isHidden = false
            btnD.isHidden = false
            
            buttons.shuffle()
            // show lifelines incase were hidden in previous questions
            lifeLineView.alpha = 1
        }
        
       let ans = temp
        var rightAns = ""
        if ans.contains("\(options.last!.lowercased())") { //last is answer here
            rightAns = options[ans.firstIndex(of: options.last!.lowercased())!]
        }else{
            rightAnswer(btn: btnA)
        }
       
        var index = 0
        for button in buttons{
            button.setTitle(options[index], for: .normal)
            if options[index] == rightAns{
                button.tag = 1
                let ans = button.currentTitle
                correctAnswer = ans!
                print(correctAnswer)
            }else{
                button.tag = 0
            }
            button.addTarget(self, action: #selector(ClickButton), for: .touchUpInside)
            button.addTarget(self, action: #selector(ButtonDown), for: .touchDown)
            index += 1
        }
        self.SetButtonHeight(buttons: btnA,btnB,btnC,btnD,btnE)
    }
    // option buttons click action
    @objc func ClickButton(button:UIButton){
        buttons.forEach{$0.isUserInteractionEnabled = false}
        if clickedButton.first?.title(for: .normal) == button.title(for: .normal){
            if button.tag == 1{
                rightAnswer(btn: button)
            }else{
                wrongAnswer(btn: button)
            }
            AddToReview(opt: button.title(for: .normal)!)
        }
    }
    
    var clickedButton:[UIButton] = []
    @objc func ButtonDown(button:UIButton){
        clickedButton.append(button)
    }
    
    // set default to four choice button
    func MakeChoiceBtnDefault(btns:UIButton...){
        for btn in btns {
            btn.isEnabled = true
            btn.resizeButton()
            btn.subviews.forEach({
                if($0.tag == 11){
                    $0.removeFromSuperview()
                }
                //find if there is any circular progress on option button and remove it
                for calayer in (btn.layer.sublayers)!{
                    if calayer.name == "circle" {
                        calayer.removeFromSuperlayer()
                    }
                }
            })
        }
    }
    // add question to review array for later review it
    func AddToReview(opt:String){
        let ques = quesData[currentQuestionPos]
        reviewQues.append(ReQuestionWithE.init(id: ques.id, question: ques.question, optionA: ques.optionA, optionB: ques.optionB, optionC: ques.optionC, optionD: ques.optionD, optionE:ques.optionE, correctAns: ques.correctAns, image: ques.image, level: ques.level, note: ques.note, quesType: ques.quesType, userSelect: opt))
    }
    
    // draw circle for audions poll lifeline
    func drawCircle(btn: UIButton, proVal: Int){
        let progRing = CircularProgressBar(radius: 20, position: CGPoint(x: btn.frame.size.width - 25, y: (btn.frame.size.height )/2), innerTrackColor: Apps.defaultInnerColor, outerTrackColor: Apps.defaultOuterColor, lineWidth: 5,progValue: 100)
        progRing.name = "circle"
        
        progRing.progressLabel.numberOfLines = 1;
        progRing.progressLabel.minimumScaleFactor = 0.6;
        progRing.progressLabel.adjustsFontSizeToFitWidth = true;
        
        btn.layer.addSublayer(progRing)
        var count:CGFloat = 0
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            count += 1
            progRing.progressManual = count
            if count >= CGFloat(proVal){
               timer.invalidate()
            }
        }
    }
    
    //show alert for not enough coins
    func ShowAlertForNotEnoughCoins(requiredCoins:Int, lifelineName:String){
        self.timer.invalidate()
        let alert = UIAlertController(title: Apps.MSG_ENOUGH_COIN, message: "\(Apps.NEED_COIN_MSG1) \(requiredCoins) \(Apps.NEED_COIN_MSG2) \n \(Apps.NEED_COIN_MSG3)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: Apps.SKIP, style: UIAlertAction.Style.cancel, handler: {action in
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.incrementCount), userInfo: nil, repeats: true)
            self.timer.fire()
        }))
        alert.addAction(UIAlertAction(title: Apps.WATCH_VIDEO, style: .default, handler: { action in
            self.callLifeLine = lifelineName
        }))
        self.present(alert, animated: true)
    }
}
