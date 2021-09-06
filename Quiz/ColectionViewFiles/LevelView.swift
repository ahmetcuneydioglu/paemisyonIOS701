import UIKit
import AVFoundation

var scoreLevel = 0
var mainCatID = 0

var numberOfItems: Int = 10

class LevelView: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var maxLevel = 0
    var catID = 0
    var mainCatid = 0
    var questionType = "sub"
    var unLockLevel =  0
    var quesData: [QuestionWithE] = []
    
    var numberOfLevels = 10
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var audioPlayer : AVAudioPlayer!
    var sysConfig:SystemConfiguration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForValues(maxLevel)

        // apps level lock unlock, no need level lock unlock remove this code
        if UserDefaults.standard.value(forKey:"\(questionType)\(catID)") != nil {
            unLockLevel = Int(truncating: UserDefaults.standard.value(forKey:"\(questionType)\(catID)") as! NSNumber)
        }
         
        if UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) != nil {
            sysConfig = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        }
         
        self.collectionView.isHidden = true
        if UserDefaults.standard.bool(forKey: "isLogedin"){
                 self.GetUserLevel()
        }else{
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
        }
    }
     


    @IBAction func backButton(_ sender: Any) {
        //check if user entered in this view directly from appdelegate ? if Yes then goTo Home page otherwise just go back from notification view
        if self == UIApplication.shared.windows.first!.rootViewController {
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
     
    @IBAction func settingButton(_ sender: Any) {
        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
     
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        maxLevel
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! levelCell
        gridCell.levelNumber.text = "\(indexPath.row + 1)"
        gridCell.circleImgView.image = UIImage(named: "circle")
        gridCell.circleImgView.tintColor = UIColor.init(named: Apps.tintArr[indexPath.row])
        if (self.unLockLevel >= indexPath.row){
            if deviceStoryBoard == "Ipad"{
                gridCell.lockButton.setBackgroundImage(UIImage(named: "unlock"), for: .normal)
            }else{
                gridCell.lockButton.setImage(UIImage(named: "unlock"), for: .normal)
            }
            gridCell.lockButton.tintColor = UIColor.gray
        }else{
            if deviceStoryBoard == "Ipad"{
                gridCell.lockButton.setBackgroundImage(UIImage(named: "lock"), for: .normal)
            }else{
                gridCell.lockButton.setImage(UIImage(named: "lock"), for: .normal)
            }
            
            gridCell.lockButton.tintColor = Apps.BASIC_COLOR
        }
        
        //if level is completed successfully - set it's text and image to grey To mark that levels as done
        if (unLockLevel >= 0 && indexPath.row < unLockLevel) {
            print("values - \(unLockLevel) - \(indexPath.row)")
            gridCell.levelNumber.textColor = Apps.LEVEL_TEXTCOLOR
            if deviceStoryBoard == "Ipad"{
                gridCell.lockButton.setBackgroundImage(UIImage(named: "unlock"), for: .normal)
            }else{
                gridCell.lockButton.setImage(UIImage(named: "unlock"), for: .normal)
            }
            gridCell.lockButton.tintColor = UIColor.gray
        }
        
        gridCell.backgroundColor = .clear
        gridCell.bgView.layer.cornerRadius = (gridCell.bgView.frame.width * 0.6 * 0.8) / 2
        gridCell.bgView.layer.masksToBounds = true
        gridCell.bgView.layer.borderColor = UIColor.lightGray.cgColor
        gridCell.bgView.layer.borderWidth = 1
                
        return gridCell
    }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                                   
            let noOfCellsInRow = 3

                let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

                let totalSpace = flowLayout.sectionInset.left
                    + flowLayout.sectionInset.right
                    + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

                let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

                return CGSize(width: size, height: size)
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            print("clicked cell number \(indexPath.row)")
            
            if (self.unLockLevel >= indexPath.row){
                
                let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
                viewCont.playType = "main"
                
                viewCont.catID = self.catID
                viewCont.level = indexPath.row + 1
                viewCont.questionType = self.questionType
                
                self.isInitial = false
                self.PlaySound(player: &audioPlayer, file: "click") // play sound
                self.Vibrate() // make device vibrate
                self.quesData.removeAll()
                var apiURL = ""
                if(questionType == "main"){
                    apiURL = "level=\(indexPath.row + 1)&category=\(catID)"
                }else{
                    apiURL = "level=\(indexPath.row + 1)&subcategory=\(catID)"
                }
                if sysConfig.LANGUAGE_MODE == 1 {
                    let langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
                    apiURL += "&language_id=\(langID)"
                }
                self.getAPIData(apiName: "get_questions_by_level", apiURL: apiURL,completion: {jsonObj in
                    print("JSON",jsonObj)
                    let status = jsonObj.value(forKey: "error") as! String
                    if (status == "true") {
                        DispatchQueue.main.async {
                            self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                        }                        
                    }else{
                        //get data for category
                        self.quesData.removeAll()
                        if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                            for val in data{
                                self.quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", optionA: "\(val["optiona"]!)", optionB: "\(val["optionb"]!)", optionC: "\(val["optionc"]!)", optionD: "\(val["optiond"]!)", optionE: "\(val["optione"]!)", correctAns: ("\(val["answer"]!)").lowercased(), image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)", quesType: "\(val["question_type"]!)"))
                            }
                            Apps.TOTAL_PLAY_QS = data.count
                            print(Apps.TOTAL_PLAY_QS)
                            
                            //check this level has enough (10) question to play? or not
                            if self.quesData.count >= Apps.TOTAL_PLAY_QS {
                                viewCont.quesData = self.quesData
                                DispatchQueue.main.async {
                                    self.navigationController?.pushViewController(viewCont, animated: true)
                                }
                            }
                        }else{
                        }
                    }
                })
            }else{
                self.ShowAlert(title: Apps.OOPS, message: Apps.LEVEL_LOCK)
            }
        }
}
extension LevelView{
    
    func GetUserLevel(){
        if(Reachability.isConnectedToNetwork()){
            let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            Loader = LoadLoader(loader: Loader)
            mainCatID = self.mainCatid
            let apiURL = self.questionType == "main" ? "user_id=\(user.userID)&category=\(self.catID)&subcategory=0" : "user_id=\(user.userID)&category=\(self.mainCatid)&subcategory=\(self.catID)"
            self.getAPIData(apiName: "get_level_data", apiURL: apiURL,completion: { jsonObj in
                 print("JSON",jsonObj)
                let status = jsonObj.value(forKey: "error") as! String
                if (status == "true") {
                    DispatchQueue.main.async {
                        self.Loader.dismiss(animated: true, completion: {
                            self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                        })
                    }
                    
                }else{
                    //close loader here
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                        DispatchQueue.main.async {
                            self.DismissLoader(loader: self.Loader)
                            let data = jsonObj.value(forKey: "data") as? [String:Any]
                           // print("level data \(data)")
                            self.unLockLevel = Int("\(data!["level"]!)")!
                            scoreLevel = self.unLockLevel
                            self.collectionView.isHidden = false
                            self.collectionView.reloadData()                            
                        }
                    });
                }
            })
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
}

class levelCell: UICollectionViewCell { 
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet var levelNumber: UILabel!
    @IBOutlet var levelTxt: UILabel!
    @IBOutlet var circleImgView: UIImageView!
    @IBOutlet weak var lockButton: UIButton!
}
