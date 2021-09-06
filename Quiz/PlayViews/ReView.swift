import Foundation
import UIKit

class ReView: UIViewController {
    
    @IBOutlet var lblQuestion: UITextView!
    @IBOutlet weak var mainQuestionTextview: UITextView!
    
    @IBOutlet weak var btnA: UIButton!
    @IBOutlet weak var btnB: UIButton!
    @IBOutlet weak var btnC: UIButton!
    @IBOutlet weak var btnD: UIButton!
    @IBOutlet weak var btnE: UIButton!
    
    @IBOutlet var nextBtn: UIButton!
    @IBOutlet var preBtn: UIButton!
    
    @IBOutlet var bookBtn: UIButton!
    @IBOutlet weak var bookMarkBtn: UIButton!
    @IBOutlet var secondChildView: UIView!
    @IBOutlet var scroll: UIScrollView!
    
    @IBOutlet weak var questionImage: UIImageView!
    @IBOutlet var mainQuestionView: UIView!
    @IBOutlet var lblQstn: UILabel!
    
    var dUser:User? = nil
        
    var ReviewQues:[ReQuestionWithE] = []
    var BookQuesList:[QuestionWithE] = []
    
    var currentQuesPosition = 0
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Apps.opt_E == true {
            btnE.isHidden = false
            //set option's view shadow
             DesignOptionButton(buttons: btnA,btnB,btnC,btnD,btnE)
        }else{
            btnE.isHidden = true
           DesignOptionButton(buttons: btnA,btnB,btnC,btnD)
        }
              
        //get bookmark list
        if (UserDefaults.standard.value(forKey: "booklist") != nil){
            BookQuesList = try! PropertyListDecoder().decode([QuestionWithE].self, from:(UserDefaults.standard.value(forKey: "booklist") as? Data)!)
        }
        
        self.secondChildView.DesignViewWithShadow()
        
        // load question when view will appear
        currentQuesPosition = 0
        self.LoadQuestion()
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
           SetExtraNote()
       }
    
    let exView = UIView()
    let button = UIButton()
    let label = UILabel()
    func SetExtraNote(){
        let color = Apps.BASIC_COLOR
        exLabel.removeFromSuperview()
        if ReviewQues[currentQuesPosition].note.isEmpty{
            
            exView.removeFromSuperview()
            button.removeFromSuperview()
            label.removeFromSuperview()
            let with = self.scroll.frame.width
                   
            self.scroll.contentSize = CGSize(width: Int(with), height: Int(btnY))
            return
        }
        exView.frame = CGRect(x: self.btnA.frame.origin.x, y: CGFloat(btnY + 20), width: self.btnA.frame.width, height: 50)
        exView.removeFromSuperview()
        
        exView.backgroundColor = Apps.WHITE_ALPHA
        exView.SetShadow()
        
        label.frame = CGRect(x: 5,y: 5, width: 250, height: 30)
        label.text = Apps.EXTRA_NOTE
        label.font = .boldSystemFont(ofSize: 15.0)
        label.textColor = color
        exView.addSubview(label)
        
        button.frame = CGRect(x: btnA.frame.width - 35 ,y: 5, width: 30, height: 30)
        button.removeFromSuperview()
        button.setTitleColor(color, for: .normal)
        button.tintColor = color
        button.tag = 0
        let image = UIImage(named: "down")
        button.setImage(image, for: .normal)        
        button.addTarget(self,action:#selector(buttonClicked),for: .touchUpInside)
        exView.addSubview(button)
        
        exView.layer.masksToBounds = true
        exView.layer.cornerRadius = 5
        exView.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 20, scale: true)
        
        self.scroll.addSubview(exView)
        let with = self.scroll.frame.width
        
        self.scroll.contentSize = CGSize(width: Int(with), height: Int(btnY) + 75)
    }
    
    let exLabel = UILabel()
    @objc func buttonClicked(sender:UIButton){
        let color = Apps.BASIC_COLOR
        let view = sender.superview
        let exNote = self.ReviewQues[self.currentQuesPosition].note

        exLabel.removeFromSuperview()
        
        if sender.tag == 0{
            let image = UIImage(named: "up")
            sender.setImage(image, for: .normal)
            let charCount = exNote.count
            let charLine = Int(charCount / 35)
            let labelHeight = charLine * 20 < 40 ? 40 : charLine * 20
            
            exLabel.frame = CGRect(x: 5,y: 50, width: Int((view?.frame.width)! - 15), height: labelHeight)
            exLabel.text = exNote
            exLabel.font = .systemFont(ofSize: 15.0)
            exLabel.textColor = color
            exLabel.numberOfLines = 0
            
            view?.frame = CGRect(x: Int((view?.frame.origin.x)!), y: Int((view?.frame.origin.y)!), width: Int((view?.frame.width)!), height: labelHeight + 80)
            view?.addSubview(exLabel)
            sender.tag = 1
            
            let with = self.scroll.frame.width
            self.scroll.contentSize = CGSize(width: Int(with), height: Int(btnY) + 75 + labelHeight)
        }else{
            exLabel.text = ""
            let image = UIImage(named: "down")
            sender.setImage(image, for: .normal)
            view?.frame = CGRect(x: self.btnA.frame.origin.x, y: CGFloat(btnY + 20), width: self.btnA.frame.width, height: 50)
            sender.tag = 0
            
            let with = self.scroll.frame.width
            self.scroll.contentSize = CGSize(width: Int(with), height: Int(btnY) + 75)
        }
    }
    
    @IBAction func msgButton(_ sender: Any) {
        let alert = UIAlertController(title: Apps.REPORT_QUESTION, message: "\(ReviewQues[currentQuesPosition].question)", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {(textField)in
            textField.placeholder = Apps.TYPE_MSG
        })
        let okAction = UIAlertAction(title:Apps.SUBMIT, style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!)->Void in
            //submit question'snote to server
            if(Reachability.isConnectedToNetwork()){
                self.dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey: "user") as? Data)!)
                print(self.dUser!)
             
                self.Loader = self.LoadLoader(loader: self.Loader)
                let apiURL = "question_id=\(self.ReviewQues[self.currentQuesPosition].id)&message=\( (alert.textFields![0].text)!)&user_id=\(self.dUser?.userID ?? "0")"
                print("API",apiURL)
                self.getAPIData(apiName: "report_question", apiURL: apiURL,completion: self.SubmitReview)
            }else{
                self.ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
            }
        })
        alert.addAction(okAction)
        alert.addAction(UIAlertAction(title: Apps.CANCEL, style: .default, handler: { action in
           
        }))
        
        self.present(alert, animated: true)
    }
    
    //load sub category data here
    func SubmitReview(jsonObj:NSDictionary){
        // print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! Bool
        if (status) {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                })
            }
        }else{
            //get data for category
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.45, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
            }
        });
    }
    
    @IBAction func bookButton(_ sender: Any) {
        if(self.bookMarkBtn.tag == 0){
            let reQues = ReviewQues[currentQuesPosition]
            self.BookQuesList.append(QuestionWithE.init(id: reQues.id, question: reQues.question, optionA: reQues.optionA, optionB: reQues.optionB, optionC: reQues.optionC, optionD: reQues.optionD, optionE: reQues.optionE, correctAns: reQues.correctAns, image: reQues.image, level: reQues.level, note: reQues.note, quesType: reQues.quesType))
            bookMarkBtn.setBackgroundImage(UIImage(named: "book-on"), for: .normal)
            bookMarkBtn.tag = 1
            self.SetBookmark(quesID: reQues.id, status: "1", completion: {})
        }else{
            let reQues = ReviewQues[currentQuesPosition]
            BookQuesList.removeAll(where: {$0.id == ReviewQues[currentQuesPosition].id && $0.correctAns == ReviewQues[currentQuesPosition].correctAns})
            bookMarkBtn.setBackgroundImage(UIImage(named: "book-off"), for: .normal)
            bookMarkBtn.tag = 0
            self.SetBookmark(quesID: reQues.id, status: "0", completion: {})
        }
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(BookQuesList), forKey: "booklist")
    }

    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nxtButton(_ sender: Any) {
        if(currentQuesPosition  < ReviewQues.count - 1){
            currentQuesPosition += 1
            self.LoadQuestion()
        }
    }
    
    @IBAction func preButton(_ sender: Any) {
        if(currentQuesPosition > 0){
            currentQuesPosition -= 1
            self.LoadQuestion()
        }
    }
    
    @IBAction func BookmarkBtn(_ sender: Any) {
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "BookmarkView")
        self.navigationController?.pushViewController(viewCont, animated: true)     
    }
    //load question
    func LoadQuestion(){
        
        if(ReviewQues.count  > currentQuesPosition && currentQuesPosition >= 0){
            lblQstn.roundCorners(corners: [.topLeft,.topRight,.bottomLeft,.bottomRight], radius: 5)
            lblQstn.text = "\(currentQuesPosition + 1) / \(Apps.TOTAL_PLAY_QS)"
            if(ReviewQues[currentQuesPosition].image == ""){
                // if question dose not have image set value here
                mainQuestionTextview.isHidden = false
                mainQuestionTextview.text = "\(ReviewQues[currentQuesPosition].question)"
                mainQuestionTextview.centerVertically()
                
                lblQuestion.isHidden = true
                questionImage.isHidden = true
            }else{
                // if question hase image set question values here
                lblQuestion.isHidden = false
                questionImage.isHidden = false
                
                lblQuestion.text = "\(ReviewQues[currentQuesPosition].question)"
                lblQuestion.centerVertically()
                
                mainQuestionTextview.isHidden = true
                
                DispatchQueue.main.async {
                    self.questionImage.loadImageUsingCache(withUrl: self.ReviewQues[self.currentQuesPosition].image)
                }
            }
            
            if ReviewQues[currentQuesPosition].optionE != ""{
              Apps.opt_E = true
              btnE.isHidden = false
              ClearColor(btns: btnA,btnB,btnC,btnD,btnE)
              self.SetViewWithShadow(views: btnA,btnB,btnC,btnD,btnE)
              btnE.setTitle("\(ReviewQues[currentQuesPosition].optionE)", for: .normal)
          }else{
              Apps.opt_E = false
              btnE.isHidden = true
              ClearColor(btns: btnA,btnB,btnC,btnD)
              self.SetViewWithShadow(views: btnA,btnB,btnC,btnD)
          }
            
            let singleReQues = ReviewQues[currentQuesPosition]
            if singleReQues.quesType == "2"{
                //set options and question label here
                btnA.setTitle("\(ReviewQues[currentQuesPosition].optionA)", for: .normal)
                btnB.setTitle("\(ReviewQues[currentQuesPosition].optionB)", for: .normal)
                
                btnC.isHidden = true
                btnD.isHidden = true
            }else{
                btnC.isHidden = false
                btnD.isHidden = false
                
                //set options and question label here
                btnA.setTitle("\(ReviewQues[currentQuesPosition].optionA)", for: .normal)
                btnB.setTitle("\(ReviewQues[currentQuesPosition].optionB)", for: .normal)
                btnC.setTitle("\(ReviewQues[currentQuesPosition].optionC)", for: .normal)
                btnD.setTitle("\(ReviewQues[currentQuesPosition].optionD)", for: .normal)
            }
           CheckUserAnswer(userAnswer: ReviewQues[currentQuesPosition].userSelect)
           self.SetButtonHeight(buttons: btnA,btnB,btnC,btnD,btnE)
            
            //check current question is in bookmark list or not
            if(BookQuesList.contains(where: {$0.id == ReviewQues[currentQuesPosition].id && $0.correctAns == ReviewQues[currentQuesPosition].correctAns})){
                self.bookMarkBtn.setBackgroundImage(UIImage(named: "book-on"), for: .normal)
                self.bookMarkBtn.tag = 1
            }else{
                self.bookMarkBtn.setBackgroundImage(UIImage(named: "book-off"), for: .normal)
                self.bookMarkBtn.tag = 0
            }
        }else{
            //question is over no more question to review
        }
    }
    
    let label1 = UILabel()
    func CheckUserAnswer(userAnswer:String){
        label1.frame = CGRect(x: 0, y: 0, width: 150, height: 20)
        label1.textColor  = .darkGray
        label1.removeFromSuperview()
        label1.text = ""
        var fontSize: CGFloat = 10
        if deviceStoryBoard == "Ipad" {
            fontSize = 20
        }
        label1.font = .systemFont(ofSize: fontSize)
        if userAnswer == ""{
            //print("Un Attemp")
            label1.text = Apps.UN_ATTEMPTED
            self.mainQuestionView.addSubview(label1)
            RightAnswer(opt: ReviewQues[currentQuesPosition].correctAns)
            return
        }
        label1.text = ""
        if ReviewQues[currentQuesPosition].optionA == userAnswer{
            if ReviewQues[currentQuesPosition].correctAns == "a"{
                RightAnswer(opt: "a")
            }else{
                WrongAnswer(opt: "a", optRight: ReviewQues[currentQuesPosition].correctAns)
            }
        }else  if ReviewQues[currentQuesPosition].optionB == userAnswer{
            if ReviewQues[currentQuesPosition].correctAns == "b"{
                RightAnswer(opt: "b")
            }else{
                WrongAnswer(opt: "b", optRight: ReviewQues[currentQuesPosition].correctAns)
            }
        }else  if ReviewQues[currentQuesPosition].optionC == userAnswer{
            if ReviewQues[currentQuesPosition].correctAns == "c"{
                RightAnswer(opt: "c")
            }else{
                WrongAnswer(opt: "c", optRight: ReviewQues[currentQuesPosition].correctAns)
            }
        }else  if ReviewQues[currentQuesPosition].optionD == userAnswer{
            if ReviewQues[currentQuesPosition].correctAns == "d"{
                RightAnswer(opt: "d")
            }else{
                WrongAnswer(opt: "d", optRight: ReviewQues[currentQuesPosition].correctAns)
            }
        }else if Apps.opt_E == true {
            if ReviewQues[currentQuesPosition].optionE == userAnswer {
                if ReviewQues[currentQuesPosition].correctAns == "e"{
                    RightAnswer(opt: "e")
                }else{
                    WrongAnswer(opt: "e", optRight: ReviewQues[currentQuesPosition].correctAns)
                }
          }
        }
    }
    //set right answer color to option
    func RightAnswer(opt:String){
        switch opt {
        case "a":
            btnA.backgroundColor = Apps.RIGHT_ANS_COLOR
            btnA.tintColor = UIColor.white
            break;
        case "b":
            btnB.backgroundColor = Apps.RIGHT_ANS_COLOR
            btnB.tintColor = UIColor.white
            break;
        case "c":
            btnC.backgroundColor = Apps.RIGHT_ANS_COLOR
            btnC.tintColor = UIColor.white
            break;
        case "d":
            btnD.backgroundColor = Apps.RIGHT_ANS_COLOR
            btnD.tintColor = UIColor.white
            break;
       case "e":
            btnE.backgroundColor = Apps.RIGHT_ANS_COLOR
            btnE.tintColor = UIColor.white
            break;
        default:
            print("unknown option selected")
        }
    }
    
    //set wrong answer and show user what is right answer
    func WrongAnswer(opt:String,optRight:String){
        //set wrong answer color to view
        switch opt {
        case "a":
            btnA.backgroundColor = Apps.WRONG_ANS_COLOR
            btnA.tintColor = UIColor.white
            break;
        case "b":
            btnB.backgroundColor = Apps.WRONG_ANS_COLOR
            btnB.tintColor = UIColor.white
            break;
        case "c":
            btnC.backgroundColor = Apps.WRONG_ANS_COLOR
            btnC.tintColor = UIColor.white
            break;
        case "d":
            btnD.backgroundColor = Apps.WRONG_ANS_COLOR
            btnD.tintColor = UIColor.white
            break;
        case "e":
            btnE.backgroundColor = Apps.WRONG_ANS_COLOR
            btnE.tintColor = UIColor.white
            break;
        default:
            print("unknown option selected")
        }
        //set right answer color to view
        RightAnswer(opt: optRight)
    }
    
    //reset options view color to default
    func ClearColor(btns:UIButton...){
        for btn in btns {
            btn.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            btn.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
        }
    }
}
