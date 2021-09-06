import Foundation
import UIKit
import AVFoundation
import Firebase

class MoreOptionsViewController: UIViewController{
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var emailAdrs: UILabel!
    
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet weak var showUserStatistics: UIButton!
    @IBOutlet weak var showBookmarks: UIButton!
    @IBOutlet weak var showNotifications: UIButton!
    @IBOutlet weak var showAboutUs: UIButton!
    @IBOutlet weak var showInstructions: UIButton!
    @IBOutlet weak var showInviteFrnd: UIButton!
    @IBOutlet weak var showTermsOfService: UIButton!
    @IBOutlet weak var showPrivacyPolicy: UIButton!
    @IBOutlet weak var logOutbtn: UIButton!
    
    var audioPlayer : AVAudioPlayer!
    var backgroundMusicPlayer: AVAudioPlayer!
    
    var controllerName:String = ""
    
    var dUser:User? = nil
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            print("user details \(dUser!) ")
            emailAdrs.text = dUser?.email
            userName.text = "\(Apps.APP_NAME)"
            imgProfile.layer.masksToBounds = true
            imgProfile.clipsToBounds = true
            
            logOutbtn.alpha = 1
            
        }else{
            logOutbtn.alpha = 0
            emailAdrs.text = ""
            userName.text = "\(Apps.APP_NAME)"
        }
        designImgView()
        imgProfile.image = UIImage(named: "homeIcon")

        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 500)
        
        // calll button design button and pass button varaible those buttons nedd to be design
        self.DesignButton(btns: showUserStatistics,showBookmarks,showInstructions,showNotifications,showInviteFrnd,showAboutUs,showPrivacyPolicy,showTermsOfService,logOutbtn)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func designImgView(){
        if #available(iOS 13.0, *) {
            imgProfile.translatesAutoresizingMaskIntoConstraints = false
            print( Apps.screenHeight)
            if Apps.screenHeight > 750 {
                imgProfile.heightAnchor.constraint(equalToConstant: 140).isActive = true
                imgProfile.widthAnchor.constraint(equalToConstant: 140).isActive = true
            }else {
                imgProfile.heightAnchor.constraint(equalToConstant: 90).isActive = true
                imgProfile.widthAnchor.constraint(equalToConstant: 90).isActive = true
            }
        }
        imgProfile.layer.masksToBounds = true
        imgProfile.clipsToBounds = true
    }
    // make button custom design function
    func DesignButton(btns:UIButton...){
        for btn in btns {
            btn.layer.cornerRadius = btn.frame.height / 3
            btn.SetShadow()
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        addTransitionAndPopViewController(.fromRight)
    }
    
    @IBAction func logOutButton(_ sender: Any){
        let alert = UIAlertController(title: Apps.LOGOUT_TITLE,message: Apps.LOGOUT_MSG,preferredStyle: .alert)        
        let imageView = UIImageView(frame: CGRect(x: 30, y: 100, width: 230, height: 100))
        imageView.image = UIImage(named: "Sad Puppy")

        alert.view.addSubview(imageView)
        
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
        
        let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        let width = NSLayoutConstraint(item: alert.view! , attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
        alert.view.addConstraint(height)
        alert.view.addConstraint(width)
        
        alert.view.tintColor = (Apps.APPEARANCE == "dark") ? UIColor.white : UIColor.black  // change text color of the buttons according to appearance of respected device
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func userStatistics(_ sender: Any) {
        self.controllerName = "UserStatistics"
        
        let myNewView=UIView(frame: CGRect(x: 10, y: 100, width: 300, height: 200))
                // Add UIView as a Subview
                self.view.addSubview(myNewView)
        
            presentViewController("UserStatistics")
        
    }
    
    @IBAction func instructions(_ sender: Any) {
        presentViewController("instructions")
    }
    
    @IBAction func bookmarks(_ sender: Any) {
        self.controllerName = "BookmarkView"
       
            presentViewController( "BookmarkView")
        
    }
    
    @IBAction func notifications(_ sender: Any) {
        self.controllerName = "NotificationsView"
       
            presentViewController("NotificationsView")
        
    }
    
    @IBAction func inviteFriends(_ sender: Any) {
        presentViewController("ReferAndEarn")
    }
    @IBAction func termsOfService(_ sender: Any) {
        self.modalTransitionStyle = .flipHorizontal
        let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: "TermsView")
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    @IBAction func privacyPolicy(_ sender: Any) {
        self.modalTransitionStyle = .flipHorizontal
        let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: "PrivacyView")
        self.navigationController?.pushViewController(viewCont, animated: true)        
    }
    
    @IBAction func aboutUs(_ sender: Any) {
        self.modalTransitionStyle = .flipHorizontal
        let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: "AboutUsView")
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    
    
    func presentViewController (_ identifier : String) {
        //click sound
        self.PlaySound(player: &audioPlayer, file: "click")
        self.Vibrate() // make device vibrate
        if (identifier == "UserStatistics") || (identifier == "UpdateProfileView") || (identifier == "ReferAndEarn") || (identifier == "BookmarkView") {
            //print("it worked for login user")
            if UserDefaults.standard.bool(forKey: "isLogedin"){
                let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: identifier)
                self.navigationController?.pushViewController(viewCont, animated: true)
            }else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else {
            //print("it is working - not login required")
            let viewCont =  Apps.storyBoard.instantiateViewController(withIdentifier: identifier)
            self.navigationController?.pushViewController(viewCont, animated: true)
        }
    }
}
extension MoreOptionsViewController {

    func adDidDismissFullScreenContent(){
    if self.controllerName == "UserStatistics"{
        presentViewController("UserStatistics")
    }else if self.controllerName == "BookmarkView"{
        presentViewController("BookmarkView")
    }else if self.controllerName == "NotificationsView"{
        presentViewController("NotificationsView")
    }else{
        self.navigationController?.popViewController(animated: true)
    }
}
    override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
    }
    
}


