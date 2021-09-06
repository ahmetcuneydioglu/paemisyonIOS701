import Foundation
import AVFoundation
import UIKit

class PaddingLabel: UILabel {

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        super.drawText(in: rect.inset(by: insets))
    }
}

class ShadowView: UIView{
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        Design()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        Design()
    }
    
    func Design(){
        self.layer.cornerRadius = 6
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0.7, height: 0.7)
        self.layer.masksToBounds = false
    }
}
