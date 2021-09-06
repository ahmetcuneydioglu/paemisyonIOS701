import Foundation
import UIKit
import Firebase

class UpdateProfileView: UIViewController{
    
    @IBOutlet var usrImg: UIImageView!
    @IBOutlet var btnUpdate: UIButton!
    @IBOutlet var logOutBtn: UIButton!
        
    @IBOutlet weak var statsBtn: UIButton!
    @IBOutlet weak var leaderboardBtn: UIButton!
    @IBOutlet weak var bookmarkBtn: UIButton!
    @IBOutlet weak var inviteBtn: UIButton!
    
    @IBOutlet var imgView: UIView!
    @IBOutlet weak var mainview: UIView!
    @IBOutlet weak var optionsView: UIView!
    
    @IBOutlet var nameTxt: FloatingTF!
    @IBOutlet var nmbrTxt: FloatingTF!
    @IBOutlet var emailTxt: FloatingTF!
    
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var email = ""
    var dUser:User? = nil
    let picker = UIImagePickerController()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
       
        statsBtn.addBottomBorderWithColor(color: UIColor(named: "blue1")!, width: 3,cornerRadius: 0)
        leaderboardBtn.addBottomBorderWithColor(color: UIColor(named: "pink1")!, width: 3,cornerRadius: 0)
        bookmarkBtn.addBottomBorderWithColor(color: UIColor(named: "orange1")!, width: 3,cornerRadius: 0)
        inviteBtn.addBottomBorderWithColor(color: UIColor(named: "green1")!, width: 3,cornerRadius: 0)
        
        usrImg.contentMode = .scaleAspectFill
        usrImg.clipsToBounds = true
        usrImg.layer.cornerRadius = usrImg.frame.height / 2
        usrImg.layer.masksToBounds = true
        usrImg.layer.borderWidth = 1.5
        usrImg.layer.borderColor =  Apps.BASIC_COLOR_CGCOLOR
        
        nameTxt.text = dUser!.name
        nmbrTxt.text = dUser!.phone
        email = dUser!.email
        emailTxt.text = dUser?.email

        DispatchQueue.main.async {
            if(self.dUser!.image != ""){
                self.usrImg.loadImageUsingCache(withUrl: self.dUser!.image)
            }
        }
                
        nmbrTxt.leftViewMode = UITextField.ViewMode.always
        if emailTxt.text != " " {
            nmbrTxt.rightViewMode = UITextField.ViewMode.always
            nmbrTxt.rightView = UIImageView(image:  UIImage(named: "edit"))
            nmbrTxt.tintColor = Apps.BASIC_COLOR
            emailTxt.leftViewMode = UITextField.ViewMode.always
        }else{
            nmbrTxt.isUserInteractionEnabled = false
        }
        nameTxt.rightViewMode = UITextField.ViewMode.always
        nameTxt.rightView = UIImageView(image:  UIImage(named: "edit"))
        nameTxt.tintColor = Apps.BASIC_COLOR
                
        //hide updt btn by default, show it on editing of any of textfields
        mainview.heightAnchor.constraint(equalToConstant: 380).isActive = true
        btnUpdate.isHidden = true
        btnUpdate.layer.cornerRadius = btnUpdate.frame.height / 2
        logOutBtn.layer.cornerRadius = logOutBtn.frame.height / 2 
        
        mainview.SetShadow()
        optionsView.SetShadow()
        logOutBtn.SetShadow()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func showUpdateButton(_ sender: Any) {
        if btnUpdate.isHidden == true{
            btnUpdate.isHidden = false
        }
    }      
    
    //load data here
    func LoadData(jsonObj:NSDictionary){
        print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.Loader.dismiss(animated: true, completion: {
                self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
            })
        }else{
            //get data for success response
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlertOnly(title: Apps.PROFILE_UPDT, message:"\(jsonObj.value(forKey: "message")!)" )
                })
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.dUser!.name = self.nameTxt.text!
                self.dUser!.phone = self.nmbrTxt.text!
                UserDefaults.standard.set(try? PropertyListEncoder().encode(self.dUser), forKey: "user")
            }
        });
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        ImagePickerManager().pickImage(self, {image in
            self.usrImg.image = image
            self.myImageUploadRequest()
        })
    }
    
    @IBAction func logoutBtn(_ sender: Any) {
        
        let alert = UIAlertController(title: Apps.LOGOUT_MSG,message: "",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            if self.dUser!.userType == "apple"{
               // if app is not loged in than navigate to loginview controller
               UserDefaults.standard.set(false, forKey: "isLogedin")
               UserDefaults.standard.removeObject(forKey: "user")
               
                let initialViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "LoginView")
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
                    
                    let initialViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "LoginView")
                    let navigationcontroller = UINavigationController(rootViewController: initialViewController)
                    navigationcontroller.setNavigationBarHidden(true, animated: false)
                    navigationcontroller.isNavigationBarHidden = true
                    UIApplication.shared.windows.first!.rootViewController = navigationcontroller
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }))
        
        alert.view.tintColor = (Apps.APPEARANCE == "dark") ? UIColor.white : UIColor.black // change text color of the buttons according to respected device appearance
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func updateButton(_ sender: Any) {
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            var apiURL = ""
            if dUser?.userType == "Mobile"{
                apiURL = "user_id=\(dUser?.userID ?? "0")&email=\(String(describing: emailTxt.text!))&name=\(String(describing: nameTxt.text!))"
            }else{
                apiURL = "user_id=\(dUser?.userID ?? "0")&email=\(String(describing: emailTxt.text!))&name=\(String(describing: nameTxt.text!))&mobile=\(String(describing: nmbrTxt.text!))"
            }         
             print(apiURL)
            self.getAPIData(apiName: "update_profile", apiURL: apiURL,completion: LoadData)
            //print("Data updated")
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    
    @IBAction func userStatisticsButton(_ sender: Any){
        let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: "UserStatistics")
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    
    @IBAction func leaderboardButton(_ sender: Any){
        let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: "Leaderboard")
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    
    @IBAction func bookmarksButton(_ sender: Any){
        let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: "BookmarkView")
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    
    @IBAction func inviteFriendsButton(_ sender: Any){
        let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: "ReferAndEarn")
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    func myImageUploadRequest(){
        
        let url = URL(string: Apps.URL)
        var request = URLRequest(url:url!);
        request.httpMethod = "POST";
        let user_id = "\(self.dUser!.userID)"
        let param = [
            "access_key"  : "\(Apps.ACCESS_KEY)",
            "upload_profile_image"    : "1",
            "user_id"    : user_id
        ]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let imageData = self.usrImg.image!.jpegData(compressionQuality: 0.5)
        
        if(imageData==nil)  {return; }
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "image", imageDataKey: imageData!, boundary: boundary) as Data
        request.addValue("Bearer \(GetTokenHash())", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {             // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {   // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                return
            }
            
            if let jsonObj = ((try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary) as NSDictionary??) {
                if (jsonObj != nil)  {
                    print("JSON",jsonObj!)
                    let status = jsonObj!.value(forKey: "error") as! String
                    if (status == "true") {
                        self.Loader.dismiss(animated: true, completion: {
                            self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj!.value(forKey: "message")!)" )
                        })
                        
                    }else{
                        //get data for success response
                        self.dUser?.image = jsonObj!.value(forKey: "file_path") as! String
                       // print("image path - \(self.dUser?.image)")
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.dUser), forKey: "user")
                    }
                }else{
                }
            }
        }
        task.resume()        
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        var body = Data();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        let filename = "\(Date().currentTimeMillis()).jpg"
        let mimetype = "image/jpg"
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}
