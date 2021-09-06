import Foundation
import UIKit
import AVFoundation
import Reachability
import SystemConfiguration

//color setting that will use in whole apps
extension UIColor{
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
        return UIColor.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
    
    static let Vertical_progress_true = Apps.RIGHT_ANS_COLOR //verticle proress bar color for true answer
    static let Vertical_progress_false = Apps.WRONG_ANS_COLOR // verticle progress bar color for false answer
    
    static func random(from colors: [UIColor]) -> UIColor? {
        return colors.randomElement()
    }
}

extension UIProgressView{
    
    // set  verticle progress bar here
    static func Vertical(color: UIColor)->UIProgressView{
            let prgressView = UIProgressView()
            prgressView.progress = 0.0
            prgressView.progressTintColor = color
            prgressView.trackTintColor = UIColor.clear
            prgressView.layer.borderColor = color.cgColor
            prgressView.layer.borderWidth = 2
            prgressView.layer.cornerRadius = 10
            prgressView.clipsToBounds = true
            prgressView.transform = CGAffineTransform(rotationAngle: .pi / -2)
            prgressView.translatesAutoresizingMaskIntoConstraints = false
            return prgressView
    }
}

extension Data {
    
    mutating func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

let imageCache = NSCache<NSString, AnyObject>()
extension UIImageView {
    func loadImageUsingCache(withUrl urlString : String) {
        let url = URL(string: urlString)
        
        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            
            return
        }
        
        // if not, download image from url
        if url != nil{
            URLSession.shared.dataTask(with: (url)!, completionHandler: { (data, response, error) in
                       if error != nil {
                           print(error!)
                           return
                       }
                       
                       DispatchQueue.main.async {
                           if let image = UIImage(data: data!) {
                               imageCache.setObject(image, forKey: urlString as NSString)
                               self.image = image
                           }
                       }
                       
                   }).resume()
        }
}
}
extension Date{
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!

    }
    
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
extension UITextView {
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
    // html tags set
    func stringFormation(_ str: String) {
        let recStr = str
        var getFont = UserDefaults.standard.float(forKey: "fontSize")
        if (getFont == 0){
            getFont = (deviceStoryBoard == "Ipad") ? 26 : 16
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        self.attributedText = recStr.htmlToAttributedString
        self.font = .systemFont(ofSize: CGFloat(getFont))
    }    
}
extension UILabel{
      
    func textChangeAnimation() {
        let animationS:CATransition = CATransition()
        animationS.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        animationS.type = CATransitionType.push
        animationS.subtype = CATransitionSubtype.fromTop
        animationS.duration = 1.50
        self.layer.add(animationS, forKey: "CATransition")
    }
   
    func textChangeAnimationToRight() {
        let animationS:CATransition = CATransition()
        animationS.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        animationS.type = CATransitionType.push
        animationS.subtype = CATransitionSubtype.fromLeft
        animationS.duration = 1.50
        self.layer.add(animationS, forKey: "CATransition")
    }   
}
extension UIButton {
    
    func resizeButton() {
        
        let btnSize = titleLabel?.sizeThatFits(CGSize(width: frame.width, height: .greatestFiniteMagnitude)) ?? .zero
        let desiredButtonSize = CGSize(width: btnSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: btnSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
        self.titleLabel?.sizeThatFits(desiredButtonSize)
    }
    func setBorder(){
        self.layer.cornerRadius = self.frame.height / 3
        self.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
        self.layer.borderWidth = 2
    }
}

extension UIView{
    func navBar(navBar: UINavigationBar){
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        navBar.backgroundColor = Apps.WHITE_ALPHA
    }
    
    func shadow(color : UIColor, offSet:CGSize, opacity: Float = 0.7, radius: CGFloat = 30, scale: Bool = true){
        DispatchQueue.main.async {
            self.layer.masksToBounds = false
            self.layer.shadowColor = color.cgColor
            self.layer.shadowOpacity = opacity
            self.layer.shadowOffset = offSet
            self.layer.shadowRadius = radius
        }
    }
    
    func applyGradient(colors: [CGColor])
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.3)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.8)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = 30
        self.layer.addSublayer(gradientLayer)
    }
    
    func DesignViewWithShadow(){
       self.layer.cornerRadius = 10
        self.backgroundColor =  UIColor.white.withAlphaComponent(0.4)
        self.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 20, scale: true)
    }
    
    func SetShadow(){
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0.7, height: 0.7)
        self.layer.masksToBounds = false
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    //battle modes
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:0,y: 0, width:self.frame.size.width, height:width)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithGradientColor(startColor: UIColor,endColor: UIColor, width: CGFloat, cornerRadius: CGFloat) {
        let border = CALayer()
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0,y: 1)
        gradientLayer.endPoint = CGPoint(x: 1,y: 0)
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: border.frame.size.width, height: border.frame.size.height)
        gradientLayer.cornerRadius = cornerRadius
        border.cornerRadius = cornerRadius
        border.addSublayer(gradientLayer)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat, cornerRadius: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        border.cornerRadius = cornerRadius
        self.layer.addSublayer(border)
    }
    
    func addCenterBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:0,y: self.frame.height / 2, width:self.frame.size.width, height:width)
        self.layer.addSublayer(border)
    }
    
    func setGradientLayer(_ color1: UIColor,_ color2: UIColor)
    {
        let gradientLayer = CAGradientLayer()
        self.backgroundColor = .clear
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0,y: 1)
        gradientLayer.endPoint = CGPoint(x: 1,y: 0)
        gradientLayer.locations = [0.50, 0.1]
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width * UIScreen.main.bounds.width, height: self.frame.size.height * UIScreen.main.bounds.height)
        if let topLayer = self.layer.sublayers?.first, topLayer is CAGradientLayer
        {
            topLayer.removeFromSuperlayer()
        }
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setCellShadow(){
        
        let subLayer = self.layer
        
        subLayer.cornerRadius = 5
        subLayer.shadowColor = UIColor.gray.cgColor
        subLayer.shadowOffset = CGSize(width: 0, height: 2)
        subLayer.shadowOpacity = 0.2 //1
        subLayer.shadowRadius = 4
        subLayer.masksToBounds = false
    }
}

extension UIViewController{
    func secondsToHoursMinutesSeconds (seconds : Int) -> String {
        if seconds % 3600 == 0{
             return "60:00"
        }
        return "\(String(format: "%02d", (seconds % 3600) / 60)):\(String(format: "%02d", (seconds % 3600) % 60))"
    }
    
    func SetOptionView(otpStr:String) -> UIView{
        let widthHeight: CGFloat = (deviceStoryBoard == "Ipad") ? 45 : 35
        let color = Apps.BASIC_COLOR
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: widthHeight, height: widthHeight))
        lbl.text = otpStr.uppercased()
        lbl.textAlignment = .center
        lbl.textColor = Apps.BASIC_COLOR
               
        let imgView = UIView(frame: CGRect(x: 3, y: 3, width: widthHeight, height: widthHeight))
        imgView.layer.cornerRadius = 4
        imgView.layer.borderColor = color.cgColor
        imgView.layer.borderWidth = 2
       
        imgView.addSubview(lbl)
        return imgView
    }
        
    
    func SetClickedOptionView(otpStr:String) -> UIView{
        let widthHeight: CGFloat = (deviceStoryBoard == "Ipad") ? 45 : 35
        
        let color = Apps.BASIC_COLOR
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: widthHeight, height: widthHeight))
        lbl.text = otpStr.uppercased()
        lbl.textAlignment = .center
        lbl.textColor = .white
        
        let imgView = UIView(frame: CGRect(x: 3, y: 3, width: widthHeight, height: widthHeight))
        imgView.layer.cornerRadius = 4
        imgView.layer.borderColor = color.cgColor
        imgView.layer.borderWidth = 1
        imgView.backgroundColor = color
        imgView.addSubview(lbl)
        return imgView
    }
    
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.windows.first!.rootViewController
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        return topMostViewController
    }
    
    func SetBookmark(quesID:String, status:String, completion:@escaping ()->Void){
         if isKeyPresentInUserDefaults(key: "user"){
             let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
             if(Reachability.isConnectedToNetwork()){
                 let apiURL = "user_id=\(user.userID)&question_id=\(quesID)&status=\(status)"
                self.getAPIData(apiName: Apps.API_BOOKMARK_SET, apiURL: apiURL,completion: {jsonObj in
                     //print("SET BOOK",jsonObj)
                    if (jsonObj.value(forKey: "data") as? [String:Any]) != nil {
                         DispatchQueue.main.async {
                             completion()
                         }
                     }
                 })
             }
         }
     }
}


extension CALayer {

    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {

        let border = CALayer()

        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }

        border.backgroundColor = color.cgColor;

        addSublayer(border)
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    var isInt: Bool {
        return Int(self) != nil
    }
}
//battle modes
extension UITextField{
    func bordredTextfield(textField: UITextField){
        textField.layer.borderWidth = 1
        textField.layer.borderColor = Apps.GRAY_CGCOLOR
        textField.layer.cornerRadius = 5
        textField.backgroundColor = UIColor.white
    }
    
    func PaddingLeft(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func bottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func AddAccessoryView(){
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = Apps.BASIC_COLOR
        toolBar.backgroundColor = .white
        toolBar.barTintColor = .white
        toolBar.sizeToFit()
        toolBar.addTopBorderWithColor(color: Apps.BASIC_COLOR, width: 1)
        
        let doneButton = UIBarButtonItem(title: Apps.DONE, style: UIBarButtonItem.Style.done, target: self, action: #selector(self.DismisPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Apps.CANCEL, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.DismisPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.inputAccessoryView = toolBar
    }
    @objc func DismisPicker(){
        self.resignFirstResponder()
    }
}
