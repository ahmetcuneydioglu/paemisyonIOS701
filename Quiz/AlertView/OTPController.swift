import UIKit
import FirebaseAuth
import Firebase

class OTPController: UIViewController ,UITextFieldDelegate{
    
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var codeTxt: UITextField!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var bgView: UIView!
    
    var frndCode = ""
    var name = ""
    var phnNum = ""
    var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeTxt.attributedPlaceholder = NSAttributedString(string:Apps.P_OTP, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        self.hideKeyboardWhenTappedAround()
        codeTxt.delegate = self
        
        self.scroll.contentSize = CGSize(width: self.view.frame.width, height: 400)
        verifyBtn.layer.cornerRadius = 10
        bgView.roundCorners(corners: [.topLeft,.topRight], radius: 15)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scroll.setContentOffset(CGPoint(x: 0,y: textField.center.y-40), animated: true)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        scroll.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
    }
    @IBAction func backButton(_ sender: Any) {
        addTransitionAndPopViewController(.fromBottom)
    }
    
    @IBAction func verifyBtn(_ sender: UIButton) {
      //check if codetxt is not empty
        print("codetxt value -- \(codeTxt.text!)")
        if  self.codeTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            self.codeTxt.becomeFirstResponder()
            let alert = UIAlertController(title: "", message: Apps.MSG_CODE, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true)
        }else{
            //verify code entered
            print(UserDefaults.standard.string(forKey: "authVerificationID") as Any)
            let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
            print(" get veri. ID \(verificationID!)")
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: "\(verificationID!)", verificationCode: "\(self.codeTxt.text!)")
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
              if let error = error {
                let authError = error as NSError
                print(authError)
                self.ShowAlert(title: Apps.ERROR, message: authError.localizedDescription)
                return
              }
                print(" authResult \(String(describing: authResult?.user))")
                print(authResult?.user.phoneNumber! as Any)
                //once verification done , login user details
                var num: String = (authResult?.user.phoneNumber)!
                num.insert(contentsOf: "%2B", at: num.startIndex) //encoded + sign - becuase + is reserved character.
                let fid = authResult?.user.uid //firebase id
                let displayname = self.name
                //random number generation
                var g = SystemRandomNumberGenerator()
                let rn = Int.random(in: 0000...9999, using: &g)
                print(rn)
                //refercode generated
                Apps.REFER_CODE = "\(displayname)\(rn)"
                Apps.REFER_CODE = self.referCodeGenerator(displayname)
                UserDefaults.standard.set(true, forKey: "isLogedin") //Bool
                let sUser = User.init(UID: "\((fid)!)",userID: "", name: "\(self.name)", email: " ", phone: "\(num)", address: " ", userType: "Mobile", image: "", status: "0",ref_code: "\(Apps.REFER_CODE)")
                UserDefaults.standard.set(try? PropertyListEncoder().encode(sUser), forKey: "user")
                // send data to server after successfully logged in
                let apiURL = "name=\(self.name)&email=&profile=&mobile=\(num)&type=mobile&fcm_id=\(Apps.FCM_ID)&ip_address=1.0.0&status=0&friends_code=\(self.frndCode)&refer_code=\(Apps.REFER_CODE)&firebase_id=\(fid!)"
                print(apiURL)
                self.getAPIData(apiName: "user_signup", apiURL: apiURL,completion: self.ProcessLogin)
            }
        }
     }
           
    //load category data here
    func ProcessLogin(jsonObj:NSDictionary){
        print("LOG",jsonObj)
        let msg = jsonObj.value(forKey: "message") as! String
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlert(title: Apps.OK, message:"\(msg)" )
                })
            }
            return
        }else{
            //get data for category
            if let data = jsonObj.value(forKey: "data") as? [String:Any] {
                //print("Data -- \(data)")
                var userD:User = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
                userD.name = "\((data["name"])!)"
                userD.userID = "\((data["user_id"])!)"
                userD.phone = "\((data["mobile"])!)"
                userD.image = "\((data["profile"])!)"
                userD.ref_code = "\((data["refer_code"])!)"
                userD.status = "\((data["status"])!)"
                UserDefaults.standard.set(try? PropertyListEncoder().encode(userD), forKey: "user")
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
                // Present main view
                let initialViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "ViewController")
                let navigationcontroller = UINavigationController(rootViewController: initialViewController)
                navigationcontroller.setNavigationBarHidden(true, animated: false)
                navigationcontroller.isNavigationBarHidden = true
                UIApplication.shared.windows.first!.rootViewController = navigationcontroller
            }
        });
    }
}
