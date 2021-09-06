import UIKit
import FirebaseAuth
import Firebase
import FirebaseCore
import GoogleSignIn
import Foundation

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var name: FloatingTF!
    @IBOutlet weak var email: FloatingTF!
    @IBOutlet weak var password: FloatingTF!
    @IBOutlet weak var referralCode: FloatingTF!
    @IBOutlet weak var pswdButton: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    
    var ref: DatabaseReference!
    
    var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference() //as it already have users, so no need to add it
        
        self.hideKeyboardWhenTappedAround()
        
        btnSignUp.setBorder()
    }
    
    //load category data here
    func LoadData(jsonObj:NSDictionary){
        print("RS",jsonObj.value(forKey: "data")!)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.Loader.dismiss(animated: true, completion: {
                self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
            })
        }else{
            //get data for category
            if let data = jsonObj.value(forKey: "data") {
                print("else part \(data)")
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
            }
        });
    }
    
    @IBAction func pswdBtn(_ sender: UIButton) {
        //change img/icon accordingly and set text secure and unsecure as button tapped
        if password.isSecureTextEntry == true {
            pswdButton.setImage(UIImage(named: "ios-eye-off"), for: UIControl.State.normal)
            password.isSecureTextEntry = false
        }else{
            pswdButton.setImage(UIImage(named: "eye"), for: UIControl.State.normal)
            password.isSecureTextEntry = true
        }
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func SignupUser(_ sender: Any) {
        //create referernce to the data user enter
        let nameTxt = name.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailTxt =  email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordTxt = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let refCodeTxt = referralCode.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //chk for name As its not optional
        if  self.name.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            self.name.becomeFirstResponder()
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
                                            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                                            let viewCont = storyboard.instantiateViewController(withIdentifier: "ViewController")
                                            
                                            self.navigationController?.pushViewController(viewCont, animated: true)
                                            
                                        }))
                                        return self.present(alert, animated: true, completion: nil)
                                        // return myAlert("user email verification sent")
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
}
