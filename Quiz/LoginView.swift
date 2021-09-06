import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FirebaseAuth
import AuthenticationServices
import CryptoKit

class LoginView: UIViewController, ASAuthorizationControllerPresentationContextProviding, UITextFieldDelegate {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }    
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var guestButton: UIButton!
    @IBOutlet weak var mobButton: UIButton!
    
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var optView: UIView!
    @IBOutlet weak var loginSignUpView: UIView!
    @IBOutlet weak var pswdButton: UIButton!
    @IBOutlet weak var emailTxt: FloatingTF!
    @IBOutlet weak var pswdTxt: FloatingTF!
    
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var btnNew: UIButton!
    
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var newView: UIView!
        
    @IBOutlet weak var sName: UITextField!
    @IBOutlet weak var sEmail:UITextField!
    @IBOutlet weak var sPassword: UITextField!
    @IBOutlet weak var sReferralCode: UITextField!
    @IBOutlet weak var sPswdButton: UIButton!
    @IBOutlet weak var sBtnSignUp: UIButton!
         
    var ref: DatabaseReference!
    
    var email = ""
  
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTxt.attributedPlaceholder = NSAttributedString(string:Apps.P_EMAIL, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        pswdTxt.attributedPlaceholder = NSAttributedString(string:Apps.P_PASSWORD, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        sName.attributedPlaceholder = NSAttributedString(string:Apps.P_NAME, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        sEmail.attributedPlaceholder = NSAttributedString(string:Apps.P_EMAIL, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        sPassword.attributedPlaceholder = NSAttributedString(string:Apps.P_PASSWORD, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        sReferralCode.attributedPlaceholder = NSAttributedString(string:Apps.P_REFERCODE, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        ref = Database.database().reference()
        
        self.hideKeyboardWhenTappedAround() //hide keyboard on tap anywhere in screen
        //rounded borders of buttons
        btnSignUp.setBorder()
        btnLogin.layer.cornerRadius = btnLogin.frame.height / 2
        btnLogin.SetShadow()
        sBtnSignUp.layer.cornerRadius =  sBtnSignUp.frame.height / 2
        sBtnSignUp.SetShadow()

        btnNew.layer.cornerRadius = btnNew.frame.height / 3
        btnNew.layer.borderColor = UIColor.white.cgColor
        btnNew.layer.borderWidth = 2
        btnAccount.layer.cornerRadius = btnAccount.frame.height / 3
        btnAccount.layer.borderColor = UIColor.white.cgColor
        btnAccount.layer.borderWidth = 2
        
        //slight curve in borders of views
        labelView.roundCorners(corners: [.topLeft, .bottomRight, .topRight, .bottomLeft], radius: 10)
        optView.roundCorners(corners: [.topLeft, .bottomRight, .topRight, .bottomLeft], radius: 10)
        loginSignUpView.roundCorners(corners: [.topLeft, .bottomRight, .topRight, .bottomLeft], radius: 10)
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
            return true
        }else {
           textField.resignFirstResponder()
           self.view.endEditing(true)
            return false
       }
    }
    
    func animateView(_ type: CATransitionSubtype) -> CATransition{
        let animationS:CATransition = CATransition()
        animationS.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        animationS.type = CATransitionType.push
        animationS.subtype = type
        animationS.duration = 0.50
        return animationS
    }
    @IBAction func newButton(_ sender: Any) {
        btnAccount.setTitleColor(UIColor.lightGray, for: .normal)
        btnNew.backgroundColor = UIColor.white
        btnNew.setTitleColor(UIColor.black, for: .normal)
        accountView.alpha = 0
        let anim = animateView(.fromLeft)
        newView.layer.add(anim, forKey: "CATransition")
        sName.text = ""
        sEmail.text = ""
        sPassword.text = ""
        sReferralCode.text = ""
        newView.alpha = 1
    }
    
    @IBAction func accountButton(_ sender: Any) {
        btnNew.setTitleColor(UIColor.lightGray, for: .normal)
        btnAccount.backgroundColor = UIColor.white
        btnAccount.setTitleColor(UIColor.black, for: .normal)
        accountView.alpha = 1
        let anim = animateView(.fromRight)
        accountView.layer.add(anim, forKey: "CATransition")
        emailTxt.text = ""
        pswdTxt.text = ""
        newView.alpha = 0
    }
    
    @IBAction func signUpBtn(_ sender: UIButton) {
        //show signup View
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "SignUpView")
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    
    @IBAction func mobileNumberLogin(_ sender: Any) {
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "SignUpMobileView")
        addTransitionAndPushViewController(viewCont, .fromTop)
    }
    @IBAction func appleSignin(_ sender: Any) {
          let nonce = randomNonceString()
          currentNonce = nonce
          let appleIDProvider = ASAuthorizationAppleIDProvider()
          let request = appleIDProvider.createRequest()
          request.requestedScopes = [.fullName, .email]
          request.nonce = sha256(nonce)

          let authorizationController = ASAuthorizationController(authorizationRequests: [request])
          authorizationController.delegate = self
          authorizationController.presentationContextProvider = self
          authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }
      return result
    }
       
        
    @IBAction func forgotPswd(_ sender: UIButton) {
        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier: "ForgotPswd") as! ForgotPswdView
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func pswdBtn(_ sender: UIButton) {
    }
    
    @IBAction func SignupUser(_ sender: Any) {
        //create referernce to the data user enter
        let nameTxt = sName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailTxt =  sEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordTxt = sPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let refCodeTxt = sReferralCode.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //chk for name As its not optional
        if  self.sName.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            self.sName.becomeFirstResponder()
            let alert = UIAlertController(title: "", message: Apps.MSG_NM, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true)
        }else{
            //create a user
            Auth.auth().createUser(withEmail: emailTxt, password: passwordTxt) { (result, err) in
                if err != nil {
                    let error_descr = err?.localizedDescription
                    if error_descr != nil {
                        print(" error -- creating user \(error_descr!)")
                        let alert = UIAlertController(title: "", message: error_descr!, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true)
                    }
                    else{
                        print("Error Creating User")
                        let alert = UIAlertController(title: "", message: Apps.MSG_ERR, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true)
                    }
                    print("Error Creating User")
                    let alert = UIAlertController(title: "", message: Apps.MSG_ERR, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true)
                }
                else {
                    //set frnd code
                    UserDefaults.standard.set(refCodeTxt, forKey: "fr_code")
                    
                    //store data to realtime database of firebase as user created successfully
                    let key = self.ref.childByAutoId().key
                    let user = [
                        "uid": key,
                        "name" : nameTxt ,
                        "ref_code" : refCodeTxt
                    ]
                    self.ref.child("users").child(key!).setValue(user){(error:Error?, ref:DatabaseReference) in
                        if let error = error {
                            let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                            self.present(alert, animated: true)
                            print("error - \(error.localizedDescription)")
                        } else {
                            guard let user = Auth.auth().currentUser else {
                                return signin(auth: Auth.auth())
                            }
                            user.reload { (error) in
                                user.sendEmailVerification { (error) in
                                    guard let error = error else {
                                        print("user verification email sent")
                                        let alert = UIAlertController(title: "", message: Apps.VERIFY_MSG1, preferredStyle: UIAlertController.Style.alert)
                                        alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: { action in
                                            self.dismissCurrView()
                                            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "LoginView")
                                            
                                            self.navigationController?.pushViewController(viewCont, animated: true)
                                            
                                        }))
                                        return self.present(alert, animated: true, completion: nil)
                                    }
                                    let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                                    self.present(alert, animated: true)
                                    print("error - \(error.localizedDescription)")
                                    // myAlert(error.localizedDescription)
                                }
                            }
                        }//else of reference error
                    } //end of reference
                } //else inside else
            } //else
        } //signup user
        
        func signin (auth: Auth){
            Auth.auth().signIn(withEmail: emailTxt, password: passwordTxt) { (result, error) in
                guard error == nil else {
                    return print(error!)
                }
                guard let user = result?.user else{
                    fatalError("User Not Found, Something went wrong")
                }
                print("Signed in user: \(user.email ?? emailTxt)")
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBAction func googleSignIn(sender: AnyObject) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GoogleSignIn.GIDSignIn.sharedInstance.signIn(with: config, presenting: self)
        self.startSignInWithGoogleFlow()
    }
    @IBAction func guestBtn(_ sender: Any) {
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ViewController")
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    func checkIfEmailVerified(){
        if Auth.auth().currentUser != nil {
            print(Auth.auth().currentUser!)
            Auth.auth().currentUser?.reload (completion: {(error) in
                if error == nil{
                    //signIn user & check whether it is verified or not ? if not verified then dnt allow to login by showing an alert
                    if Auth.auth().currentUser?.isEmailVerified == true {
                        self.signInVerification()
                    }else{
                        let alert = UIAlertController(title: Apps.RESET_MSG, message: Apps.VERIFY_MSG, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }else{
                    let alert = UIAlertController(title: Apps.ERROR, message: error!.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true)
                    print(error?.localizedDescription ?? "error")
                }
            })
        }else{
            signInVerification()
        }
    }
    func signInVerification(){
        //create referernce to the data user enter
        let username = self.emailTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.pswdTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: username, password: password) { (result,error) in
            if error != nil {
                let alert = UIAlertController(title: Apps.ERROR, message: error!.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true)
                print(error!.localizedDescription)
            }else{
               
                //set DisplayName by splitting from given email address
                let displayname = result?.user.email!.components(separatedBy: "@")
                let nm = displayname![0]
                //print("\(nm)")
                var fcode = ""
                var rcode = nm
                Apps.REFER_CODE = rcode
                print("curr user -- \((result?.user.uid)!)")
                var mobile = "0"
                if result?.user.phoneNumber != nil {
                    mobile = (result?.user.phoneNumber)!
                }
                if result?.user.displayName != nil {
                    rcode = self.referCodeGenerator((result?.user.displayName)!)
                }else{
                    rcode = self.referCodeGenerator(nm)
                }
               
                Apps.REFER_CODE = rcode
                
                if (UserDefaults.standard.value(forKey: "fr_code") != nil){
                    fcode = UserDefaults.standard.string(forKey: "fr_code")!
                    print(fcode)
                }else{
                    fcode = " "
                }
                let sUser = User.init(UID: "\((result?.user.uid)!)",userID: "", name: "\(result?.user.displayName ?? "\(nm)")", email: "\((result?.user.email)!)",phone: "\(result?.user.phoneNumber ?? "")", address: " ", userType: "email", image: "", status: "0",ref_code: "\(rcode)") //,frnd_code: "\(fcode)"
                
                UserDefaults.standard.set(try? PropertyListEncoder().encode(sUser), forKey: "user")
                print("user data-- \(sUser)")
                
                // send data to server after successfully loged in
                let apiURL = "firebase_id=\(result?.user.uid ?? "0")&name=\(result?.user.displayName ?? "\(nm)")&email=\((result?.user.email)!)&profile=&mobile=\(mobile)&type=email&fcm_id=\(Apps.FCM_ID)&refer_code=\(rcode)&friends_code=\(fcode)&ip_address=1.0.0&status=0" //\(result?.user.uid)
                self.getAPIData(apiName: "user_signup", apiURL: apiURL,completion: self.ProcessLogin)
                UserDefaults.standard.set(true, forKey: "isLogedin")
                let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ViewController")
                self.navigationController?.pushViewController(viewCont, animated: true)
            }
        }
    }
    @IBAction func loginBtn(_ sender: UIButton)
    {
        if emailTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || pswdTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            print("Please enter correct username and password")
            let alert = UIAlertController(title: "", message: Apps.CORRECT_DATA_MSG, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true)
        } else{
            checkIfEmailVerified()
        }
    }
 
    func startSignInWithGoogleFlow() {
         // [START headless_google_auth]
         guard let clientID = FirebaseApp.app()?.options.clientID else { return }

         // Create Google Sign In configuration object.
         let config = GIDConfiguration(clientID: clientID)

         // Start the sign in flow!
         GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in

           if let error = error {
             // [START_EXCLUDE]
             self.ShowAlert(title: "", message: error.localizedDescription)
             // [END_EXCLUDE]
             return
           }

           // [START google_credential]
           guard
             let authentication = user?.authentication,
             let idToken = authentication.idToken
           else {
             return
           }

           let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                          accessToken: authentication.accessToken)
           // [END google_credential]
            Auth.auth().signIn(with: credential) { (user, error) in
                 if error != nil {//let error = error
                     // error signin
                     return
                 }
     
                 var number = "0"
                 if user?.user.phoneNumber != nil{
                     number = (user?.user.phoneNumber)!
                 }
     
                 let displayname = user?.user.email!.components(separatedBy: "@")
                 let nm = displayname![0]
                 //print("\(nm)")
                 var rcode = nm
                 Apps.REFER_CODE = rcode
                 rcode = self.referCodeGenerator((user?.user.displayName)!)
                 Apps.REFER_CODE = rcode
     
                 UserDefaults.standard.set(true, forKey: "isLogedin") //Bool
                 let sUser = User.init(UID: "\((user?.user.uid)!)",userID: "", name: "\((user?.user.displayName)!)", email: "\((user?.user.email)!)", phone: "\(String(describing: user?.user.phoneNumber))", address: " ", userType: "gmail", image: "\((user?.user.photoURL)!)", status: "0",ref_code: "\(rcode)")
                 UserDefaults.standard.set(try? PropertyListEncoder().encode(sUser), forKey: "user")
     
                 // send data to server after successfully loged in
                 let apiURL = "firebase_id=\(sUser.UID)&name=\((user?.user.displayName)!)&email=\((user?.user.email)!)&profile=\((user?.user.photoURL)!)&mobile=\(number)&type=gmail&fcm_id=\(Apps.FCM_ID)&refer_code=\(rcode)&ip_address=1.0.0&status=0"
                 self.getAPIData(apiName: "user_signup", apiURL: apiURL,completion: self.ProcessLogin)
             }
         }
         // [END headless_google_auth]
       }
    
    @IBAction func facebookLogin(sender: UIButton) {
        let fbLoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = AccessToken.current else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: Apps.ERROR, message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: Apps.OK, style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                var number = "0"
                if user?.user.phoneNumber != nil {
                    number = (user?.user.phoneNumber)!
                }
                var emailID = "x@x.com"
                if user?.user.email == nil {
                    emailID = "\((user?.user.uid)!)@fb.com"
                }else{
                    emailID = (user?.user.email)!
                }
                var rcode = ""
                var display_Nm = ""
                if user?.user.displayName != nil {
                    display_Nm = (user?.user.displayName)!
                    rcode = self.referCodeGenerator((user?.user.displayName)!)
                }else{
                    display_Nm = "fbUser"
                    rcode = self.referCodeGenerator("fbUser")
                }
                Apps.REFER_CODE = rcode
                
                UserDefaults.standard.set(true, forKey: "isLogedin")
                let sUser = User.init(UID: "\((user?.user.uid)!)",userID: "", name: "\(display_Nm)", email: "\(emailID)", phone: "\(number)", address: " ",userType: "fb", image: "\((user?.user.photoURL)!)", status: "0",ref_code: "\(rcode)")
                
                UserDefaults.standard.set(try? PropertyListEncoder().encode(sUser), forKey: "user")
                
                // send data to server after successfully loged in
                self.Loader = self.LoadLoader(loader: self.Loader)
                let apiURL = "firebase_id=\(user?.user.uid ?? "0")&name=\(display_Nm)&email=\(emailID)&profile=\((user?.user.photoURL)!)&mobile=\(number)&type=fb&fcm_id=\(Apps.FCM_ID)&refer_code=\(rcode)&ip_address=1.0.0&status=0"
                print(apiURL)
                self.getAPIData(apiName: "user_signup", apiURL: apiURL,completion: self.ProcessLogin)
            })
        }
    }
    
    @IBAction func PrivacyBtn(_ sender: Any) {
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "PrivacyView") as! PrivacyView
        viewCont.isLoginPage = true
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    
    @IBAction func TermsBtn(_ sender: Any) {
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "TermsView") as! TermsService
        viewCont.isLoginPage = true
        self.navigationController?.pushViewController(viewCont, animated: true)
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
                print("Data -- \(data)")
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
                // Present the main view
                let initialViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "ViewController")                
                let navigationcontroller = UINavigationController(rootViewController: initialViewController)
                navigationcontroller.setNavigationBarHidden(true, animated: false)
                navigationcontroller.isNavigationBarHidden = true                
                UIApplication.shared.windows.first!.rootViewController = navigationcontroller
            }
        });
    }
}
@available(iOS 13.0, *)
extension LoginView: ASAuthorizationControllerDelegate {

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        print("Unable to fetch identity token")
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        return
      }
      // Initialize a Firebase credential.
      let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                idToken: idTokenString,
                                                rawNonce: nonce)
      // Sign in with Firebase.
      Auth.auth().signIn(with: credential) { (authResult, error) in
        if (error != nil) {
          // Error. If error.code == .MissingOrInvalidNonce, make sure
          // you're sending the SHA256-hashed nonce as a hex string with
          // your request to Apple.
            print(error!.localizedDescription)
          return
        }
        // User is signed in to Firebase with Apple.
        print("apple user details -- \(authResult?.user.uid ?? "No data")")
        var nm = authResult?.user.displayName
        var refCode = ""
        if nm == nil {
            let displayname = authResult?.user.email!.components(separatedBy: "@")
            nm = displayname![0]
        }
        refCode = self.referCodeGenerator(nm!)
        Apps.REFER_CODE = refCode
            
        let uid = authResult?.user.providerID.replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range: nil)
        let sUser = User.init(UID: "\(authResult?.user.uid ?? "nil")",userID: "", name: "\(nm ?? "apple user")", email: "\(authResult?.user.email ?? "\(uid ?? "0")@privaterelay.appleid.com")", phone: "0", address: " ",userType: "apple", image: "", status: "0", ref_code: "\(refCode)")
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(sUser), forKey: "user")
        UserDefaults.standard.set(true, forKey: "isLogedin") //Bool
        
        // send data to server after successfully loged in
        self.Loader = self.LoadLoader(loader: self.Loader)
        let apiURL = "name=\(nm ?? "apple user")&email=\(authResult?.user.email ?? "\(uid ?? "0")@privaterelay.appleid.com")&profile=&type=apple&fcm_id=\(Apps.FCM_ID)&ip_address=1.0.0&status=0&firebase_id=\(authResult?.user.uid ?? "nil")&refer_code=\(refCode)"
        self.getAPIData(apiName: "user_signup", apiURL: apiURL,completion: self.ProcessLogin)
        
      }
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }
}
