import Foundation
import  UIKit

class GradientButton: UIButton {
       @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
       @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
       @IBInspectable var startLocation: CGPoint = .zero { didSet { updateLocations() }}
       @IBInspectable var endLocation:   CGPoint =  .zero { didSet { updateLocations() }}
       @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
       @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}
       @IBInspectable var cornerRadius: CGFloat = 0 { didSet{ updateCornerRadius() }}

       override public class var layerClass: AnyClass { CAGradientLayer.self }

       var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

       func updatePoints() {
           if horizontalMode {
               gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
               gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
           } else {
               gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
               gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
           }
       }
       func updateLocations() {
           gradientLayer.startPoint = startLocation
           gradientLayer.endPoint = endLocation
       }
       func updateColors() {
           gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
       }
    func updateCornerRadius() {
              gradientLayer.cornerRadius = cornerRadius
      }
       override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
           super.traitCollectionDidChange(previousTraitCollection)
           updatePoints()
           updateLocations()
           updateColors()
           updateCornerRadius()
       }
}
