import UIKit

class SelfAttempAlertView: UIViewController {

    @IBOutlet var scrolView:UIScrollView!
    
    var bottomAlertData:[Int] = []
    var noOfQues = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.AddTimeButton(scrollView: scrolView)
    }
    
    @IBAction func ClosAlert(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
    func AddTimeButton(scrollView:UIScrollView){
        
        let buttonPadding:CGFloat = 10
        var xOffset:CGFloat = 10
        
        for i in 1...noOfQues {
            let button = UIButton()
            button.tag = i
            button.setTitle("\(i)", for: .normal)
            button.accessibilityLabel = "time"
           
            let color = Apps.BASIC_COLOR
            button.frame = CGRect(x: xOffset, y: CGFloat(buttonPadding), width: 35, height: 35)
            
            button.layer.cornerRadius = 35 / 3
            button.layer.borderColor = color.cgColor
            
            button.layer.borderWidth = 1
            if self.bottomAlertData.contains(i){
                button.backgroundColor = color
                button.setTitleColor(.white, for: .normal)
            }else{
                button.backgroundColor = UIColor.clear
                button.setTitleColor(color, for: .normal)
            }            
            xOffset = xOffset + CGFloat(buttonPadding) + button.frame.size.width
            scrollView.addSubview(button)
        }
        scrollView.contentSize = CGSize(width: xOffset, height: scrollView.frame.height)
    }
}
