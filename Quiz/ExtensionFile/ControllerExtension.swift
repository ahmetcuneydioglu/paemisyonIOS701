import Foundation
import UIKit
//import FirebaseInstanceID
import AVFoundation
import Reachability
import SystemConfiguration
import SwiftyJWT

extension UIViewController{
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func hideCurrViewWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissCurrView))
        tap.numberOfTapsRequired = 2
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissCurrView() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //play sound
    func PlaySound(player:inout AVAudioPlayer!,file:String){
        let soundURL = Bundle.main.url(forResource: file, withExtension: "mp3")
        do {
            player = try AVAudioPlayer(contentsOf: soundURL!)
        }
        catch {
            print(error)
        }
        let setting = try! PropertyListDecoder().decode(Setting.self, from: (UserDefaults.standard.value(forKey:"setting") as? Data)!)
        if setting.sound {
            player.play()
        }
    }
    
    func PlayBackgrounMusic(player:inout AVAudioPlayer!,file:String){
        let soundURL = Bundle.main.url(forResource: file, withExtension: "mp3")
        do {
            player = try AVAudioPlayer(contentsOf: soundURL!)
            player.numberOfLoops = -1
            player.prepareToPlay()
            
            if(UserDefaults.standard.value(forKey:"setting") == nil){
                UserDefaults.standard.set(try? PropertyListEncoder().encode(Setting.init(sound: true, backMusic: false, vibration: true)),forKey: "setting")
            }
            let setting = try! PropertyListDecoder().decode(Setting.self, from: (UserDefaults.standard.value(forKey:"setting") as? Data)!)
            
            if setting.backMusic {
                player.play()
            }
        }
        catch {
            print(error)
        }
    }
    
    //do device vibration
    func Vibrate(){
        let setting = try! PropertyListDecoder().decode(Setting.self, from: (UserDefaults.standard.value(forKey:"setting") as? Data)!)
        if setting.vibration {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    // generate JWT Token Hash
       func GetTokenHash() -> String {
        let headerWithKeyId = JWTHeader.init(keyId:Apps.JWT)

           var payload = JWTPayload()
           payload.expiration = Int(Date(timeIntervalSinceNow: 60).timeIntervalSince1970)
           payload.issuer = "quiz"
           payload.subject = "quiz Authentication"
           payload.issueAt = Int(Date().timeIntervalSince1970)
           let alg = JWTAlgorithm.hs256(Apps.JWT)
           let jwtWithKeyId = JWT.init(payload: payload, algorithm: alg, header: headerWithKeyId)
        
           return jwtWithKeyId!.rawString!
       }

    
    // get api data
    func getAPIData(apiName:String, apiURL:String,completion:@escaping (NSDictionary)->Void,image:UIImageView? = nil){
              
        let url = URL(string: Apps.URL)!
        let postString = "access_key=\(Apps.ACCESS_KEY)&\(apiName)=1&\(apiURL)"
                print("POST URL",url)
                print("POST String = \(postString)")
            //  print("token \(GetTokenHash())")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = Data(postString.utf8)
        request.addValue("Bearer \(GetTokenHash())", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {             // check for fundamental networking error
                print("error=\(String(describing: error))")
                let res = ["status":false,"message":"JSON Parser Error - NW Error"] as NSDictionary
                completion(res)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {   // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                let res = ["status":false,"message":"JSON Parser Error - HTTP Error"] as NSDictionary
                completion(res)
                return
            }
            
            if let jsonObj = ((try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary) as NSDictionary??) {
                if (jsonObj != nil)  {
                    completion(jsonObj!)
                }else{
                    let res = ["status":false,"message":"JSON Parser Error - API Error"] as NSDictionary
                    completion(res)
                    print("JSON API ERROR",String(data: data, encoding: String.Encoding.utf8)!)
                }
            }else{
                let res = ["error":"false","message":"Error while fetching data"] as NSDictionary
                print("JSON API ERROR",String(data: data, encoding: String.Encoding.utf8)!)
                completion(res)
            }
        }
        task.resume()
    }
    //refer code generator
    func referCodeGenerator(_ displayNm: String) -> String {
        let displayname = displayNm
        var g = SystemRandomNumberGenerator()
        let rn = Int.random(in: 0000...9999, using: &g)
        let referCode = (displayname)+String(rn)
        
        return referCode
    }
    //random Numbers for battle game room code
    func randomNumberForBattle() -> String {
        var g = SystemRandomNumberGenerator()
        let rn = Int.random(in: 00000...99999, using: &g)//5 digits
        var code = String(rn)
        if code.count < 5 {
            code = "0\(code)"
        }
        print(code)
        return code
    }
   
        
    //load loader
    func LoadLoader(loader:UIAlertController)->UIAlertController{
        let pending = UIAlertController(title: nil, message: Apps.WAIT , preferredStyle: .alert)
        
        pending.view.tintColor = (Apps.APPEARANCE == "dark") ? UIColor.white : UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x:10,y:5), size: CGSize(width: 50, height: 50))) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
          
        pending.view.addSubview(loadingIndicator)
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2, execute: {
            DispatchQueue.main.async {
                self.present(pending, animated: true, completion: nil)
            }
        });
        return pending 
    }
    //show alert view here with any title and messages
    func ShowAlert(title:String,message:String){
        
        let attributedTitle = NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor : Apps.BASIC_COLOR
        ])

        let attributedMsg = NSAttributedString(string: message, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13),
            NSAttributedString.Key.foregroundColor : (Apps.APPEARANCE == "dark") ? UIColor.white : UIColor.black
        ])
                
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = Apps.BASIC_COLOR
        alert.addAction(UIAlertAction(title: Apps.OKAY, style: UIAlertAction.Style.cancel, handler: nil))
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.45, execute: {
            DispatchQueue.main.async {
                self.getTopMostViewController()?.present(alert, animated: true, completion: nil)
            }
        });
        alert.setValue((attributedTitle), forKey: "attributedTitle")
        alert.setValue(attributedMsg, forKey: "attributedMessage")
    }
    //show alert view here with any title and messages & without button
    func ShowAlertOnly(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for c  in 0...15 {
            if c == 0 {
                self.present(alert, animated: true)
            }
            if c == 15 {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    //dismiss loader
    func DismissLoader(loader:UIAlertController){
        loader.dismiss(animated: true, completion: nil)
    }
    
    func battleOpponentAnswer(btn: UIButton, str: String){
        var lblWidth:CGFloat = 90
        var lblHeight:CGFloat = 25
        var fontSize: CGFloat = 12
        
        if deviceStoryBoard == "Ipad" {
            lblWidth = 180
            lblHeight = 50
            fontSize = 24
        }
        let lbl = UILabel(frame: CGRect(x: btn.frame.size.width - (lblWidth + 5) ,y: (btn.frame.size.height - lblHeight)/2, width: lblWidth, height: lblHeight))
        lbl.textAlignment = .center
        lbl.text = "\(str)"
        lbl.tag = 11 // identified tag for remove it from its super view
        lbl.clipsToBounds = true
        lbl.layer.cornerRadius = lblHeight / 3
        if btn.tag == 1{ // true answer
            lbl.textColor = Apps.RIGHT_ANS_COLOR
        }else{ //wrong answer
            lbl.textColor = Apps.WRONG_ANS_COLOR
        }
        lbl.backgroundColor = UIColor.white
        lbl.font = .systemFont(ofSize: fontSize)
        btn.addSubview(lbl)
    }
    
    // reachability class
    public class Reachability {
        class func isConnectedToNetwork() -> Bool {
            
            var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
            zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                    SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
                }
            }
            var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
            if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
                return false
            }
            
            // Working for Cellular and WIFI
            let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
            let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
            let ret = (isReachable && !needsConnection)
            return ret
            
        }
    }
    //design image view
    func DesignImageView(_ images:UIImageView...){
        for image in images{
            image.layer.backgroundColor = UIColor.white.cgColor
            image.layer.masksToBounds = false
            image.clipsToBounds = true
            image.layer.cornerRadius = image.frame.width / 2
        }
    }
        
    func RegisterNotification(notificationName:String){
        NotificationCenter.default.addObserver(self,selector: #selector(self.Dismiss),name: NSNotification.Name(rawValue: notificationName),object: nil)
    }
    func addTransitionAndPushViewController(_ viewCont : UIViewController,_ type: CATransitionSubtype){
        let transition = CATransition.init()
        transition.duration = 0.4
        transition.type = .push
        transition.subtype = type
        self.navigationController?.view.layer.add(
                transition,
                forKey: kCATransition)
        self.navigationController?.pushViewController(viewCont, animated: false)
    }
    func addTransitionAndPopViewController(_ type: CATransitionSubtype){
        let transition = CATransition.init()
        transition.duration = 0.4
        transition.type = .reveal
        transition.subtype = type
        self.navigationController?.view.layer.add(
                transition,
                forKey: kCATransition)
        self.navigationController?.popViewController(animated: false)
    }
    @objc func Dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    func CallNotification(notificationName:String){
        NotificationCenter.default.post(name: Notification.Name(notificationName), object: nil)
    }
    
    // set verticle progress bar here
    func setVerticleProgress(view:UIView, progress:UIProgressView){
        view.addSubview(progress)
        progress.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progress.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        progress.widthAnchor.constraint(equalToConstant: view.frame.size.height).isActive = true
        progress.heightAnchor.constraint(equalToConstant: 20).isActive = true
        progress.setProgress(0, animated: true)
    }
    
    //design four choice view function
    func SetViewWithShadow(views:UIView...){
        for view in views{
            DispatchQueue.main.async {
                view.layer.cornerRadius =  10
            }
        }
    }
    
    // design option button
    func DesignOptionButton(buttons: UIButton...){
        for button in buttons{
            button.contentMode = .center
           // button.SetShadow()
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.lineBreakMode = .byWordWrapping
        }
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func checkForValues(_ diff : Int){
        if Apps.arrColors1.count < diff {
            let dif = diff - (Apps.arrColors1.count - 1)
            print("difference - \(dif)")
            for i in 0...dif{
                Apps.arrColors1.append(Apps.arrColors1[i])
                Apps.arrColors2.append(Apps.arrColors2[i])
                Apps.tintArr.append(Apps.tintArr[i])
            }
        }
    }
}

extension UIView {
    
    func createImage() -> UIImage {
        
        let rect: CGRect = self.frame 
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }    
}

extension String {
    var bool: Bool? {
        switch self.lowercased() {
        case "true", "t", "yes", "y", "1":
            return true
        case "false", "f", "no", "n", "0":
            return false
        default:
            return nil
        }
    }
}
