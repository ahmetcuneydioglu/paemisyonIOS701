import Foundation
import UIKit

class backButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 3 { didSet{ updateCornerRadius() }}
    
    
    func updateCornerRadius() {
        self.layer.cornerRadius = cornerRadius
    }
    func SetbgShadow(){
       // self.layer.cornerRadius = 3
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.3, height: 0.4)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 1.0//4
        self.layer.masksToBounds = false
    }
    
    override func awakeFromNib() {
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        self.backgroundColor = UIColor.white
        SetbgShadow()
    }
}
