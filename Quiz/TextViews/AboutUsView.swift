import Foundation
import UIKit

class AboutUsView: UIViewController{
    @IBOutlet var txtView: UITextView!
    
    var isInitial = true 
    var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            let apiURL = ""
            self.getAPIData(apiName: "get_about_us", apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    
    //load category data here
    func LoadData(jsonObj:NSDictionary){
        var htmlData = ""
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.Loader.dismiss(animated: true, completion: {
                self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
            })
        }else{
            //get data for category
            if let data = jsonObj.value(forKey: "data") as? String {
               htmlData = data 
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
                let htmlData = NSString(string: htmlData).data(using: String.Encoding.unicode.rawValue)
                let options = [NSAttributedString.DocumentReadingOptionKey.documentType:
                    NSAttributedString.DocumentType.html]
                let attributedString = try? NSMutableAttributedString(data: htmlData ?? Data(),
                                                                      options: options,
                                                                      documentAttributes: nil)
                self.txtView.attributedText = attributedString
            }
        });
    }
    @IBAction func backButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            self.navigationController?.popToViewController( (self.navigationController?.viewControllers[1]) as! HomeScreenController, animated: true)
        }
    }
}
