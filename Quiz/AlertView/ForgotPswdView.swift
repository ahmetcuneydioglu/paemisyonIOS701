import UIKit
import Firebase
import FirebaseAuth

class ForgotPswdView: UIViewController , UITextFieldDelegate {
    
    @IBOutlet weak var email: FloatingTF!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    var emailTxt = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        email.attributedPlaceholder = NSAttributedString(string:Apps.P_EMAILTXT, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        btnSubmit.layer.cornerRadius = 15
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 600)
        bgView.roundCorners(corners: [.topLeft, .topRight ], radius: 25)
     }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0,y: textField.center.y-40), animated: true)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        scrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //hide keyboard on click of done / return key
            self.view.endEditing(true)
            return false
    }
    func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitBtn(_ sender: UIButton) {
        print("button clicked !!!")
        if email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            email.placeholder? = Apps.ENTER_MAILID
            email.placeHolderColor = UIColor.red
             }
        else{
            //send new pswd link to given mail id
             Auth.auth().sendPasswordReset(withEmail: email.text ?? emailTxt, completion: { (error) in
                     //Make sure you execute the following code on the main queue
                     DispatchQueue.main.async {
                         //Use "if let" to access the error, if it is non-nil
                         if let error = error {
                            let resetFailedAlert = UIAlertController(title: Apps.RESET_FAILED , message: error.localizedDescription, preferredStyle: .alert)
                            resetFailedAlert.addAction(UIAlertAction(title: Apps.OK, style: .default, handler: nil))
                            //do nothing or give chance to enter proper email
                            self.present(resetFailedAlert, animated: true, completion: nil)
                         } else {
                            let resetEmailSentAlert = UIAlertController(title: Apps.RESET_TITLE, message: Apps.RESET_MSG, preferredStyle: .alert)
                            resetEmailSentAlert.addAction(UIAlertAction(title: Apps.OK, style: .default, handler: { action in
                                self.dismissView()
                            }))
                             self.present(resetEmailSentAlert, animated: true, completion: nil)
                         }
                     }
                 })
            }
     }
    @IBAction func CloseAlert(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
}
