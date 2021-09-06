import UIKit
import Firebase
import AVFoundation

class HomeScreenController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet weak var allTimeScoreButton: UIButton!
    @IBOutlet weak var coinsButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet var languageButton: UIButton!
    @IBOutlet var iAPButton: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    
    var audioPlayer : AVAudioPlayer!
    var backgroundMusicPlayer: AVAudioPlayer!
    var setting:Setting? = nil
    
    var sysConfig:SystemConfiguration!
    var Loader: UIAlertController = UIAlertController()
    
    let varSys = SystemConfig()
    var userDATA:UserScore? = nil
    var dUser:User? = nil
    
    var config:SystemConfiguration?
    var apiName = "get_categories"
    var apiExPeraforLang = ""
    var catData:[Category] = []
    var langList:[Language] = []
    
    var arr = [Apps.QUIZ_ZONE,Apps.PLAY_ZONE,Apps.BATTLE_ZONE,Apps.CONTEST_ZONE]
    let leftImg = [Apps.IMG_QUIZ_ZONE,Apps.IMG_PLAYQUIZ,Apps.IMG_BATTLE_QUIZ,Apps.IMG_CONTEST_QUIZ]
    
    //battle modes
    var ref: DatabaseReference!
    var roomDetails:RoomDetails?
    var isUserBusy = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
            
        if Apps.CONTEST_MODE == "0"{
            arr.removeLast() //as contest mode is last element there
        }
        
        self.PlayBackgrounMusic(player: &backgroundMusicPlayer, file: "snd_bg")
        
        leaderboardButton.layer.cornerRadius = leaderboardButton.frame.height / 2
        leaderboardButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        allTimeScoreButton.layer.cornerRadius = leaderboardButton.frame.height / 2
        allTimeScoreButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        coinsButton.layer.cornerRadius = leaderboardButton.frame.height / 2
        coinsButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        
        iAPButton.layer.cornerRadius = iAPButton.frame.height / 3
        languageButton.layer.cornerRadius = languageButton.frame.height / 3
        //check setting object in user default
        if UserDefaults.standard.value(forKey:"setting") != nil {
            setting = try! PropertyListDecoder().decode(Setting.self, from: (UserDefaults.standard.value(forKey:"setting") as? Data)!)
        }else{
            setting = Setting.init(sound: true, backMusic: false, vibration: true)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.setting), forKey: "setting")
        }
        
        //check score object in user default
        if UserDefaults.standard.value(forKey:"UserScore") != nil {
            //available
        }else{
            // not availabel add it to user default
            UserDefaults.standard.set(try? PropertyListEncoder().encode(UserScore.init(coins: 0, points: 0)), forKey: "UserScore")
        }
        
        //register nsnotification for latter call for play music and stop music
        NotificationCenter.default.addObserver(self,selector: #selector(self.PlayBackMusic),name: NSNotification.Name(rawValue: "PlayMusic"),object: nil) // for play music
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.StopBackMusic),name: NSNotification.Name(rawValue: "StopMusic"),object: nil) // for stop music
                
        if UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) != nil {
            sysConfig = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        }
        getUserNameImg()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
        varSys.getDeviceInterfaceStyle()
        
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            if self.isUserBusy{
                self.isUserBusy = false
            }
        }
    }    

    func logOutUserAndGoBackToLogin(){
        if self.dUser!.userType == "apple"{
           // if app is not loged in than navigate to loginview controller
           UserDefaults.standard.set(false, forKey: "isLogedin")
           UserDefaults.standard.removeObject(forKey: "user")
           
            
           let initialViewController =  Apps.storyBoard.instantiateViewController(withIdentifier: "LoginView")
           
           let navigationcontroller = UINavigationController(rootViewController: initialViewController)
           navigationcontroller.setNavigationBarHidden(true, animated: false)
           navigationcontroller.isNavigationBarHidden = true
           
            UIApplication.shared.windows.first!.rootViewController = navigationcontroller
           return
       }
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                UserDefaults.standard.removeObject(forKey: "isLogedin")
                //remove friend code
                UserDefaults.standard.removeObject(forKey: "fr_code")
                
                let initialViewController =  Apps.storyBoard.instantiateViewController(withIdentifier: "LoginView")
                let navigationcontroller = UINavigationController(rootViewController: initialViewController)
                navigationcontroller.setNavigationBarHidden(true, animated: false)
                navigationcontroller.isNavigationBarHidden = true
                UIApplication.shared.windows.first!.rootViewController = navigationcontroller
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    func getUserNameImg(){
        //user name and display image
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            //print("user data - \(dUser)")
            if dUser?.status == "0" { //user status is - deactivated
                ShowAlert(title: Apps.DEACTIVATED, message: "\(Apps.HELLO) \(dUser!.name)\n \(Apps.DEACTIVATED_MSG)")
                logOutUserAndGoBackToLogin()
            }
            userName.text = "\(Apps.HELLO)  \(dUser!.name)"
          
            imgProfile.layer.cornerRadius =  imgProfile.frame.height / 2
            imgProfile.layer.masksToBounds = true
            imgProfile.clipsToBounds = true
            imgProfile.layer.borderWidth = 2
            imgProfile.layer.borderColor = UIColor.white.cgColor
            
            imgProfile.isUserInteractionEnabled = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            imgProfile.addGestureRecognizer(tapRecognizer)
            
            DispatchQueue.main.async {
                if(self.dUser!.image != ""){
                    self.imgProfile.loadImageUsingCache(withUrl: self.dUser!.image)
                }else{
                    self.imgProfile.image = UIImage(systemName: "person.fill")
                }
            }
        }else{
            userName.text = "\(Apps.HELLO) \(Apps.USER)"
            imgProfile.image = UIImage(systemName: "person.fill")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        languageButton.isHidden = true
        iAPButton.isHidden = true
        if Apps.IN_APP_PURCHASE == "1" {
            iAPButton.isHidden = false
        }
        if isKeyPresentInUserDefaults(key: DEFAULT_SYS_CONFIG){
            let config = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
            if config.LANGUAGE_MODE == 1{
                languageButton.isHidden = false
                //open language view
                if UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG) == 0{
                    LanguageButton(self)
                }
            }
        }
        
        if isKeyPresentInUserDefaults(key: "isLogedin"){
            if !UserDefaults.standard.bool(forKey: "isLogedin"){
                return
            }
        }else{
            return
        }
        
        leaderboardButton.setTitle(Apps.ALL_TIME_RANK as? String , for: .normal)
        allTimeScoreButton.setTitle(Apps.SCORE as? String, for: .normal)
        coinsButton.setTitle(Apps.COINS , for: .normal) 
        
        varSys.getUserDetails()

        getUserNameImg()
    }
    
    @objc func imageTapped(gestureRecognizer: UITapGestureRecognizer) {
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: "UpdateProfileView")
            self.navigationController?.pushViewController(viewCont, animated: true)
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func moreBtn(_ sender: UIButton) {
        
        let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: "MoreOptions")
        addTransitionAndPushViewController(viewCont,.fromLeft)
    }    
    
    // play background music function
    @objc func PlayBackMusic(){
        backgroundMusicPlayer.play()
    }
    
    // stop background music function
    @objc func StopBackMusic(){
        backgroundMusicPlayer.stop()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func showAllCategories(){
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: "subcategoryview") as! subCategoryViewController
        self.navigationController?.pushViewController(viewCont, animated: true)
        
    }
    @IBAction func leaderboardBtn(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "isLogedin"){
             
            let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: "Leaderboard")
            self.navigationController?.pushViewController(viewCont, animated: true)
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    @IBAction func LanguageButton(_ sender: Any){
         
        let view =  Apps.storyBoard.instantiateViewController(withIdentifier: "LanguageView") as! LanguageView
        view.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        view.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(view, animated: true, completion: nil)
    }
    @IBAction func IAPButton(_ sender: Any){
         
        let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: "CoinStoreViewController") as! CoinStoreViewController
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    
//tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier = "QuizZone"
        if indexPath.row == 1 {
            cellIdentifier = "PlayZone"
        }
        if indexPath.row == 0 {
            cellIdentifier = "QuizZone"
        }
        if indexPath.row == 2 {
            cellIdentifier = "BattleZone"
        }
        if indexPath.row == 3 {
            cellIdentifier = "ContestZone"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HomeTableViewCell
        //print("test -- \(arr[indexPath.row])")
        
        cell.titleLabel.text = arr[indexPath.row]
        cell.titleLabel.frame = (deviceStoryBoard == "Ipad") ? CGRect(x: 80, y: 10, width: 508, height: 25) : CGRect(x: 52, y: 11, width: 270, height: 20)
        cell.leftImg.image = UIImage(named: leftImg[indexPath.row])
        cell.leftImg.frame = (deviceStoryBoard == "Ipad") ? CGRect(x: 9, y: 4, width: 61, height: 28) : CGRect(x: 9, y: 5, width: 33, height: 28)
        
        cell.cellDelegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightVal:CGFloat = 0
        if indexPath.row == 1 || indexPath.row == 2 { //playzone OR BattleZone
            heightVal = (deviceStoryBoard == "Ipad" ? 800 : 350)
            return heightVal
        }else{
            heightVal = (deviceStoryBoard == "Ipad" ? 400 : 225)
            return heightVal
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected - \(indexPath.row)")
    }
    
    @IBAction func viewAllCategory(_ sender: Any) {
         
        let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: "categoryview") as! CategoryViewController
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
}
extension HomeScreenController:CellSelectDelegate{
        
   
    func didCellSelected(_ type: String,_ rowIndex: Int){    
        if type == "playzone-0"{
            getQuestions("daily")
        }else if type == "playzone-1"{
            getQuestions("random")
        }else if type == "playzone-2"{
            getQuestions("true/false")
        }else if type == "playzone-3"{
            let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: "SelfChallengeController")
            self.navigationController?.pushViewController(viewCont, animated: true)
        }else if type == "battlezone-0"{
            if UserDefaults.standard.bool(forKey: "isLogedin"){
              let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: "GroupBattleTypeSelection")
              self.navigationController?.pushViewController(viewCont, animated: true)
            }else{
              self.navigationController?.popToRootViewController(animated: true)
            }
        }else if type == "battlezone-1"{
            if UserDefaults.standard.bool(forKey: "isLogedin"){
                if Apps.RANDOM_BATTLE_WITH_CATEGORY == "1"{
                     let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: "categoryview") as! CategoryViewController
                    //pass value to identify to jump to battle and not play quiz view.
                    viewCont.isCategoryBattle = true
                    self.navigationController?.pushViewController(viewCont, animated: true)
                }else{
                    let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: "BattleViewController")
                    self.navigationController?.pushViewController(viewCont, animated: true)
                }
            }else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else if type == "ContestView" {
            if UserDefaults.standard.bool(forKey: "isLogedin"){
               
              let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: type)
              self.navigationController?.pushViewController(viewCont, animated: true)
            }else{
              self.navigationController?.popToRootViewController(animated: true)
            }
        }else{
            self.PlaySound(player: &audioPlayer, file: "click") // play sound
            self.Vibrate() // make device vibrate
            //check if language is enabled and not selected
            if languageButton.isHidden == false{
                if UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG) == 0 {
                    LanguageButton(self)
                }
            }
            if type == "subcategoryview"{
                let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: type) as! subCategoryViewController
                if (UserDefaults.standard.value(forKey: "categories") != nil){
                    self.catData = try! PropertyListDecoder().decode([Category].self,from:(UserDefaults.standard.value(forKey: "categories") as? Data)!)
                }
                viewCont.catID = catData[rowIndex].id
                viewCont.catName = catData[rowIndex].name
                print("call subcategoryview with id and name - \(catData[rowIndex].id) - \(catData[rowIndex].name)")
                self.navigationController?.pushViewController(viewCont, animated: true)
            }else if type == "LevelView"{
                let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: type) as! LevelView
                if (UserDefaults.standard.value(forKey: "categories") != nil){
                    self.catData = try! PropertyListDecoder().decode([Category].self,from:(UserDefaults.standard.value(forKey: "categories") as? Data)!)
                }
                if catData[rowIndex].maxlvl != "0" { //if there's no levels or no questions then do nothing 
                    if catData[rowIndex].maxlvl.isInt{
                        viewCont.maxLevel = Int(catData[rowIndex].maxlvl)!
                    }
                    viewCont.catID = Int(self.catData[rowIndex].id)!
                    viewCont.questionType = "main"
                    self.navigationController?.pushViewController(viewCont, animated: true)
                }else{
                    ShowAlertOnly(title: "", message: Apps.NOT_ENOUGH_QUESTION_TITLE)
                }
                
            }else{
                let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: type)
                self.navigationController?.pushViewController(viewCont, animated: true)
            }            
        }
    }
    
    
    enum VersionError: Error {
        case invalidResponse, invalidBundleInfo
    }
    
    func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String else {
                    throw VersionError.invalidResponse
                }
                completion(version != currentVersion, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
    
    func CheckAppsUpdate(){
        _ = try? isUpdateAvailable { (update, error) in
            if let error = error {
                print("APPS UPDATE",error)
            } else if let update = update {
                print("Apps UPDATE - ",update)
            }
        }
    }
    
    func popupUpdateDialogue(){
        let alert = UIAlertController(title: Apps.UPDATE_TITLE, message: Apps.UPDATE_MSG, preferredStyle: .alert)
        
        let okBtn = UIAlertAction(title: Apps.UPDATE_BUTTON, style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if let url = URL(string: Apps.SHARE_APP),
                UIApplication.shared.canOpenURL(url){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        })
        let noBtn = UIAlertAction(title:Apps.SKIP , style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
        })
        alert.addAction(okBtn)
        alert.addAction(noBtn)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func getQuestions(_ type: String){ //type should be random,true/false or daily only
        let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView

        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        var quesData: [QuestionWithE] = []
        var apiURL = ""
        var apiName = "get_daily_quiz"
        
        if sysConfig.LANGUAGE_MODE == 1{
            let langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
            apiURL += "language_id=\(langID)"
        }
        
        Loader = LoadLoader(loader: Loader)
        if type == "random"{
            apiName = "get_questions_by_type" //"get_random_questions"
            apiURL += "&type=1&limit=\(Apps.TOTAL_PLAY_QS)&"  //type 1=normal ,2 = true/false
            viewCont.titlebartext = "Random Quiz"
            viewCont.playType = "RandomQuiz"
        }else if type == "true/false"{
            apiName = "get_questions_by_type"
            apiURL += "&type=2&limit=\(Apps.TOTAL_PLAY_QS)"
            viewCont.titlebartext = "True/False"
            viewCont.playType = "true/false"
        }else{ //Daily
            apiName = "get_daily_quiz"
            apiURL += "&user_id=\(dUser?.userID ?? "1")"
            viewCont.playType = "daily"
        }
        self.getAPIData(apiName: "\(apiName)", apiURL: apiURL,completion: {jsonObj in
            print("api name and url - \(apiName) - \(apiURL)")
            print("JSON",jsonObj)
            //close loader here
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                DispatchQueue.main.async {
                    self.DismissLoader(loader: self.Loader)
                }
            });
            let status = jsonObj.value(forKey: "error") as! String
            if (status == "true") {
                let msg = jsonObj.value(forKey: "message")! as! String
                if msg != "" && msg == "daily quiz already played" {
                    self.DismissLoader(loader: self.Loader)
                    self.ShowAlert(title: Apps.PLAYED_ALREADY, message: Apps.PLAYED_MSG)
                }else{
                    var apiURL = ""
                    if self.sysConfig.LANGUAGE_MODE == 1{
                           let langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
                           apiURL = "&language_id=\(langID)"
                    }
                    if viewCont.playType != "daily" {
                        self.getAPIData(apiName: "get_random_questions_for_computer", apiURL: apiURL,completion: loadQuestions)
                    }else{
                        DispatchQueue.main.async {
                            self.DismissLoader(loader: self.Loader)
                            self.ShowAlert(title: Apps.NO_QSTN, message: Apps.NO_QSTN_MSG)
                        }
                    }
                }
            }else{
               loadQuestions(jsonObj: jsonObj)
            }
        })
        
        func loadQuestions(jsonObj:NSDictionary){
            //get data for category
            quesData.removeAll()
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", optionA: "\(val["optiona"]!)", optionB: "\(val["optionb"]!)", optionC: "\(val["optionc"]!)", optionD: "\(val["optiond"]!)", optionE: "\(val["optione"]!)", correctAns: ("\(val["answer"]!)").lowercased(), image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)", quesType: "\(val["question_type"]!)"))
                }
                
                Apps.TOTAL_PLAY_QS = data.count
                
                //check this level has enough (10) question to play? or not
                if quesData.count >= Apps.TOTAL_PLAY_QS {
                    viewCont.quesData = quesData
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.6, execute: {
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(viewCont, animated: true)
                        }
                    })                   
                }
            }
        }
    }
}
