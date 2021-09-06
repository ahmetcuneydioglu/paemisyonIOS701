import UIKit

@IBDesignable class GradientView: UIImageView
{
     @IBInspectable var gradientColor1: UIColor = UIColor.white {
        didSet{
            self.setGradient()
        }
    }
    
    @IBInspectable var gradientColor2: UIColor = UIColor.white {
        didSet{
            self.setGradient()
        }
    }
    
    @IBInspectable var gradientStartPoint: CGPoint = .zero {
        didSet{
            self.setGradient()
        }
    }
    
    @IBInspectable var gradientEndPoint: CGPoint = CGPoint(x: 1, y: 1) {
        didSet{
            self.setGradient()
        }
    }
    
    private func setGradient()
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [self.gradientColor1.cgColor, self.gradientColor2.cgColor]
        gradientLayer.startPoint = self.gradientStartPoint
        gradientLayer.endPoint = self.gradientEndPoint
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width * Apps.screenWidth, height: self.frame.size.height * Apps.screenHeight)
        if let topLayer = self.layer.sublayers?.first, topLayer is CAGradientLayer
        {
            topLayer.removeFromSuperlayer()
        }
        self.layer.addSublayer(gradientLayer)
    }
}
