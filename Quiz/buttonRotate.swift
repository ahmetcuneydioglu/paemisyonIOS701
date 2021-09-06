import UIKit

class buttonRotate: UIButton {
    
    override func awakeFromNib() {
        let animation = spinAnimation()
        self.layer.add(animation!, forKey: "rotationAnimation")
    }
    func spinAnimation() -> CABasicAnimation? {
        let anim = CABasicAnimation(keyPath: "transform.rotation.z")
        anim.toValue = NSNumber(value: Double.pi * 2.0)
        anim.duration = CFTimeInterval(1.8)
        anim.isCumulative = true
        anim.repeatCount =  .infinity
        return anim
    }
}
