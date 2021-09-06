import UIKit

class ReferAndEarnView: UIViewController {

    @IBOutlet weak var referBtn: UIButton!
    @IBOutlet weak var referCode: UILabel!
    
    @IBOutlet weak var referText: UILabel!
    
    var dUser:User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        referText.text = "\(Apps.REFER_MSG1) \(Apps.EARN_COIN) \(Apps.REFER_MSG2)"
        
        dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        print("user details \(dUser!) ")
        referCode.text = dUser?.ref_code
        referCode.createDottedBorder(cornerRadius: referCode.frame.height / 2 )
        referBtn.layer.cornerRadius = referBtn.frame.height / 2
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        //copy refercode to clipboard
        UIPasteboard.general.string = referCode.text
        ShowAlertOnly(title: "", message: Apps.REFER_CODE_COPY)
    }
    
    @IBAction func referNow(_ sender: Any) {
      
        let shareText = Apps.SHARE_APP_TXT
        guard let url = URL(string: Apps.SHARE_APP) else { return }
        let msgTxt = "\(Apps.SHARE_MSG) \" \(referCode.text!) \" "
        let shareContent: [Any] = [shareText, msgTxt,"\n", url]
        let activityController = UIActivityViewController(activityItems: shareContent,applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = sender as? UIView
        self.present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
       }
}
