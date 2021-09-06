import UIKit
import AVFoundation

class SelfChallengeController: UIViewController {
        
    @IBOutlet var mainCatField:UITextField!
    @IBOutlet var subCatField:UITextField!
    @IBOutlet var startBtn:UIButton!
    @IBOutlet var quesScroll:UIScrollView!
    @IBOutlet var timeScroll:UIScrollView!
    
    var catData:[Category] = []
    var subCatData:[SubCategory] = []
    var Loader: UIAlertController = UIAlertController()
    
    var mainPicker = UIPickerView()
    var subPicker = UIPickerView()
    
    var userSelectedMainCatID = ""
    var userSelectedSubCatID = ""
    var userSelectedtTime = 0
    var userSelectedQues = 0
    
    var audioPlayer : AVAudioPlayer!
    var sysConfig:SystemConfiguration!
    var catID = 0
    var questionType = "sub"
    var quesData: [QuestionWithE] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        if UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) != nil {
            sysConfig = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        }
        
        
        self.DesignTextField(textFields: mainCatField,subCatField)
        
        self.AddTimeButton(scrollView: timeScroll)
        
        self.startBtn.layer.cornerRadius = self.startBtn.frame.height / 2
        
        self.mainPicker.delegate = self
        self.mainPicker.dataSource = self
        
        self.subPicker.delegate = self
        self.subPicker.dataSource = self
        
        self.DesignPicker(picker: self.mainPicker)
        self.DesignPicker(picker: self.subPicker)
        
        self.mainCatField.inputView = self.mainPicker
        self.mainCatField.inputAccessoryView = self.ToolBarView()
        self.mainCatField.delegate = self
        
        self.subCatField.inputView = self.subPicker
        self.subCatField.inputAccessoryView = self.ToolBarView()
        self.subCatField.delegate = self
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            var apiName = "get_categories"
            var apiURL = ""
            if sysConfig?.LANGUAGE_MODE == 1{
                apiName = "get_categories_by_language"
                apiURL = "&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))"
            }
           
            self.getAPIData(apiName:apiName, apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    
    //load category data here
    func LoadData(jsonObj:NSDictionary){
        //print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                })
            }
            
        }else{
            //get data for category
            catData.removeAll()
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    catData.append(Category.init(id: "\(val["id"]!)", name: "\(val["category_name"]!)", image: "\(val["image"]!)", maxlvl: "\(val["maxlevel"]!)", noOf: "\(val["no_of"]!)", noOfQues: "\(val["no_of_que"]!)"))
                }
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
                self.mainPicker.reloadAllComponents()
            }
        });
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func PlayAction(_ sender: Any) {
        
        if self.userSelectedQues == 0{
            self.ShowAlert(title: Apps.ALERT_TITLE, message: "")
            return
        }
        
        if self.userSelectedtTime == 0{
            self.ShowAlert(title: Apps.ALERT_TITLE1, message: "")
            return
        }
      
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "SelfChallenegePlay") as! SelfChallengePlay
        viewCont.catID = self.catID
        viewCont.questionType = self.questionType
        viewCont.quizPlayTime = self.userSelectedtTime
        
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        self.quesData.removeAll()
        var apiURL = ""
        if(questionType == "main"){
            apiURL = "category=\(self.userSelectedMainCatID)"
        }else{
            apiURL = "subcategory=\(self.userSelectedSubCatID)"
        }
        if sysConfig.LANGUAGE_MODE == 1{
            let langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
            apiURL += "&language_id=\(langID)"
        }
        apiURL += "&limit=\(self.userSelectedQues)"
        self.getAPIData(apiName: "get_questions_for_self_challenge", apiURL: apiURL,completion: {jsonObj in
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
                        //check if admin have added questions with 5 options? if not, then hide option E btn by setting boolean variable to false even if option E mode is Enabled.
                        if let e = val["optione"] as? String {
                            if e == ""{
                                Apps.opt_E = false
                            }else{
                                Apps.opt_E = true
                            }
                        }
                    }
                    Apps.TOTAL_PLAY_QS = data.count
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
    }
    
    func DesignTextField(textFields:UITextField...){
        for field in textFields{
            field.layer.cornerRadius = field.frame.height / 2
            field.leftViewMode = .always
            field.leftView = UIView(frame: CGRect(x: 10, y: 0, width: 10, height: field.frame.height))
            
            let view = UIView(frame: CGRect(x: -10, y: 5, width: 30, height: field.frame.height))
            let img =  UIImageView(image: UIImage(named: "droparrow"))
            img.tintColor = .white
            img.contentMode = .center
            img.frame  = CGRect(x: -10, y: -5, width: field.frame.height, height: field.frame.height)
            
            view.addSubview(img)
            
            field.rightViewMode = .always
            field.rightView = view
        }
    }
    
    func AddQuesButton(scrollView:UIScrollView, toVal:Int){
        
        scrollView.subviews.forEach({$0.removeFromSuperview()})
        let buttonPadding:CGFloat = 10
        var xOffset:CGFloat = 10
        
        if toVal < 5{
            let label = UILabel(frame: CGRect(x: 10, y: 5, width: 200, height: 30))
            label.text = Apps.NO_BOOKMARK //"Questions not available"
            label.textColor = .black
             scrollView.addSubview(label)
            return
        }
      
        for i in stride(from: 5, to: toVal + 1, by: 5) {
          
            let button = UIButton()
            button.tag = i
            button.backgroundColor = UIColor.darkGray
            button.setTitle("\(i)", for: .normal)
            button.accessibilityLabel = "ques"
            button.addTarget(self, action: #selector(self.ButtonClicked(_:)), for: UIControl.Event.touchUpInside)
            let color = Apps.BASIC_COLOR
            button.frame = CGRect(x: xOffset, y: CGFloat(buttonPadding), width: 60, height: 35)
            
            button.layer.cornerRadius = 35 / 3
            button.layer.borderColor = color.cgColor
            
            button.setTitleColor(color, for: .normal)
            button.layer.borderWidth = 1
            
            button.backgroundColor = UIColor.clear
            
            xOffset = xOffset + CGFloat(buttonPadding) + button.frame.size.width
            scrollView.addSubview(button)
        }
        scrollView.contentSize = CGSize(width: xOffset, height: scrollView.frame.height)
    }
    
    func AddTimeButton(scrollView:UIScrollView){
        
        let buttonPadding:CGFloat = 10
        var xOffset:CGFloat = 10
        
        for i in stride(from: 3, to: 63, by: 3) {
            let button = UIButton()
            button.tag = i
            button.backgroundColor = UIColor.darkGray
            button.setTitle("\(i)", for: .normal)
            button.accessibilityLabel = "time"
            button.addTarget(self, action: #selector(self.ButtonClicked(_:)), for: UIControl.Event.touchUpInside)
            let color = Apps.BASIC_COLOR
            button.frame = CGRect(x: xOffset, y: CGFloat(buttonPadding), width: 60, height: 35)
            
            button.layer.cornerRadius = 35 / 3
            button.layer.borderColor = color.cgColor
            
            button.setTitleColor(color, for: .normal)
            button.layer.borderWidth = 1
            
            button.backgroundColor = UIColor.clear
            
            xOffset = xOffset + CGFloat(buttonPadding) + button.frame.size.width
            scrollView.addSubview(button)
        }
        scrollView.contentSize = CGSize(width: xOffset, height: scrollView.frame.height)
    }
    
    @objc func ButtonClicked(_ sender:UIButton){
        let color = Apps.BASIC_COLOR
        if sender.accessibilityLabel! == "ques"{
            self.quesScroll.subviews.forEach({
                $0.backgroundColor = UIColor.clear
                if let btn = $0 as? UIButton{
                    btn.setTitleColor(color, for: .normal)
                }
            })
            sender.backgroundColor = color
            sender.setTitleColor(UIColor.white, for: .normal)
            print("QUES",sender.tag)
            self.userSelectedQues = sender.tag
        }else if sender.accessibilityLabel! == "time"{
            self.timeScroll.subviews.forEach({
                $0.backgroundColor = UIColor.clear
                if let btn = $0 as? UIButton{
                    btn.setTitleColor(color, for: .normal)
                }
            })
            sender.backgroundColor = color
            sender.setTitleColor(UIColor.white, for: .normal)
            print("TIME",sender.tag)
            self.userSelectedtTime = sender.tag
        }
    }
}

extension SelfChallengeController:UIPickerViewDataSource,UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.mainPicker{
            return self.catData.count
        }else{
            return self.subCatData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.mainPicker{
            return self.catData[row].name
        }else{
            return self.subCatData[row].name + "     \(Apps.STR_QUE): \(self.subCatData[row].noOf)"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.mainPicker{
            self.mainCatField.text = self.catData[row].name
            self.userSelectedMainCatID = self.catData[row].id
            self.questionType = "main"
            self.subPicker.isHidden = false
            if self.catData[row].noOf == "0"{
                self.subPicker.isHidden = true
                self.AddQuesButton(scrollView: quesScroll,toVal: Int("\(self.catData[row].noOfQues)")!)
            }
        }else{
            self.questionType = "sub"
            self.subCatField.text = self.subCatData[row].name
            self.AddQuesButton(scrollView: quesScroll,toVal: Int("\(self.subCatData[row].noOf)")!)
            self.userSelectedSubCatID = self.subCatData[row].id
        }
    }
    
    func DesignPicker(picker:UIPickerView){
        picker.delegate = self as UIPickerViewDelegate
        picker.dataSource = self as UIPickerViewDataSource
        picker.backgroundColor = UIColor.black
        
        picker.tintColor = UIColor.white
        picker.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    func ToolBarView() -> UIToolbar{
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.barTintColor = UIColor.black
        toolBar.tintColor = UIColor.white
        toolBar.backgroundColor = UIColor.black
        
        let button = UIBarButtonItem(title: Apps.DONE, style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    
    @objc func action() {
        view.endEditing(true)
    }
    
    func RequestSubCat(mainCatID:String){
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            let apiURL = "main_id=\(mainCatID)"
            self.getAPIData(apiName: "get_subcategory_by_maincategory", apiURL: apiURL,completion: { jsonObj in
                print("RS",jsonObj)
                let status = jsonObj.value(forKey: "error") as! String
                if (status == "true") {
                }else{
                    //get data for category
                    self.subCatData.removeAll()
                    if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                        for val in data{
                            self.subCatData.append(SubCategory.init(id: "\(val["id"]!)", name: "\(val["subcategory_name"]!)", image: "\(val["image"]!)", maxlevel: "\(val["maxlevel"]!)", status: "\(val["status"]!)", noOf: "\(val["no_of"]!)"))
                        }
                    }
                }
                //close loader here
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.45, execute: {
                    DispatchQueue.main.async {
                        self.DismissLoader(loader: self.Loader)
                        self.subPicker.reloadAllComponents()
                    }
                });
            })
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
}

extension SelfChallengeController:UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.mainCatField{
            if self.userSelectedMainCatID != ""{
                self.RequestSubCat(mainCatID: self.userSelectedMainCatID)
            }
        }
    }
}
