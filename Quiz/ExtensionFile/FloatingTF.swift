import UIKit
import QuartzCore
let floatingTitleLabelHeight = 10
public extension String {
  
  func substring(_ r: Range<Int>) -> String {
    let fromIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
    let toIndex = self.index(self.startIndex, offsetBy: r.upperBound)
    return String(self[Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex))])
  }
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.height
    }
}

class FloatingTF: UITextField {
var bottomLineLayer = CALayer()
  let animationDuration = 0.3
  var isFloatingTitleHidden = true
  var title = UILabel()
    var bubbleLayer = CAShapeLayer()
  
  public var setErrorAlertActive :Bool = false {
    didSet {
      if setErrorAlertActive {
      bottomLineLayer.backgroundColor = errorBottomLineColor.cgColor
      }
    }
  }

  required init?(coder aDecoder:NSCoder) {
    super.init(coder:aDecoder)
    setup()
  }
  
  override init(frame:CGRect) {
    super.init(frame:frame)
    setup()
  }
  fileprivate func setup() {
    borderStyle = UITextField.BorderStyle.none
    titleActiveTextColor = tintColor
    // Set up title label
    title.alpha = 0.0
    title.font = titleFont
    title.textColor = titleActiveTextColor
    if let str = placeholder , !str.isEmpty {
      title.text = str.capitalized
      title.sizeToFit()
    }
    self.addSubview(title)
    bottomLineLayer.backgroundColor = UIColor.red.cgColor.copy(alpha: 0.5)
    self.layer.addSublayer(bottomLineLayer)
    self.clipsToBounds = false
  }
  
  @IBInspectable var enableFloatingTitle : Bool = false
  public var titleFont : UIFont = UIFont.systemFont(ofSize: 10)

  @IBInspectable var activeBottomLineColor:UIColor = UIColor.clear {
    didSet {
      if isFirstResponder {
        bottomLineLayer.backgroundColor = activeBottomLineColor.cgColor
      }
    }
  }
  @IBInspectable var inactiveBottomLineColor:UIColor = UIColor.clear {
    didSet {
            if !isFirstResponder {
      bottomLineLayer.backgroundColor = inactiveBottomLineColor.cgColor
            }
    }
  }
  @IBInspectable var errorBottomLineColor:UIColor = UIColor.clear {
    didSet {
            if !isFirstResponder && setErrorAlertActive {
      bottomLineLayer.backgroundColor = errorBottomLineColor.cgColor
            }
    }
  }
  @IBInspectable var titleActiveTextColor:UIColor = UIColor.clear {
    didSet {
//      if isFirstResponder {
        title.textColor = titleActiveTextColor
        tintColor = titleActiveTextColor
//      }
    }
  }
  @IBInspectable var titleInactiveTextColor:UIColor = UIColor.clear {
    didSet {
      if isFirstResponder {
        title.textColor = titleInactiveTextColor
      }
    }
  }
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
  override func layoutSubviews() {
    super.layoutSubviews()
    setBottomLineLayerFrame()
    
    let isActive = isFirstResponder
    if isActive {
      bottomLineLayer.backgroundColor = activeBottomLineColor.cgColor
      title.textColor = titleActiveTextColor
        bubbleLayer.removeFromSuperlayer()

    }
    if !isActive {
      bottomLineLayer.backgroundColor = inactiveBottomLineColor.cgColor
      title.textColor = titleInactiveTextColor

    }
    
    if setErrorAlertActive {
      bottomLineLayer.backgroundColor = errorBottomLineColor.cgColor
      title.textColor = titleInactiveTextColor
    }
    setErrorAlertActive = false
    
    if let txt = text , txt.isEmpty {
      // Hide
        if !isFloatingTitleHidden {
      hideTitle(isActive)
        }
    } else if enableFloatingTitle{
        setTitleFrame()

      // Show
      showTitle(isActive)

    }
  }

	private func setBottomLineLayerFrame() {
    bottomLineLayer.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
	}
  
  fileprivate func showTitle(_ animated:Bool) {
    let dur = animated ? animationDuration : 0
    UIView.animate(withDuration: dur, delay:0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseOut], animations:{
      // Animation
      self.title.text = self.placeholder
      self.title.alpha = 1.0
      var r = self.title.frame
        r.origin.y = -(CGFloat)(1.5)
      self.title.frame = r
    }, completion:{ _ in
        self.isFloatingTitleHidden = false
    })
  }
  
  fileprivate func hideTitle(_ animated:Bool) {
    self.isFloatingTitleHidden = true

    let dur = animated ? animationDuration : 0
    UIView.animate(withDuration: dur, delay:0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseIn], animations:{
      // Animation
      self.title.alpha = 0.0
      var r = self.title.frame
      r.origin.y = self.title.font.lineHeight + 0
      self.title.frame = r
    }, completion:{ _ in
        })
  }

	private func setTitleFrame() {
        self.title.frame = CGRect(x:0, y:-floatingTitleLabelHeight, width:Int(self.frame.size.width), height:floatingTitleLabelHeight)
	}
}
var borderWidth : CGFloat = 0 // Should be less or equal to the `radius` property
var radius : CGFloat = 0
var triangleHeight : CGFloat = 15

private func bubblePathForContentSize(contentSize: CGSize) -> UIBezierPath {
    let rect = CGRect(x:0, y:0, width: contentSize.width, height: contentSize.height).offsetBy(dx: radius, dy: radius + triangleHeight)
    let path = UIBezierPath();
    let radius2 = radius - borderWidth / 2 // Radius adjusted for the border width
    
    path.move(to: CGPoint(x:rect.maxX - triangleHeight * 2,y: rect.minY - radius2))
    path.addLine(to: CGPoint(x:rect.maxX - triangleHeight, y:rect.minY - radius2 - triangleHeight))  
    
    path.addArc(withCenter: CGPoint(x:rect.maxX, y:rect.minY), radius: radius2, startAngle: CGFloat(-Double.pi / 2), endAngle: 0, clockwise: true)
    path.addArc(withCenter: CGPoint(x:rect.maxX,y: rect.maxY), radius: radius2, startAngle: 0, endAngle: CGFloat(Double.pi / 2), clockwise: true)
    path.addArc(withCenter: CGPoint(x:rect.minX,y: rect.maxY), radius: radius2, startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi ), clockwise: true)
    path.addArc(withCenter: CGPoint(x:rect.minX,y: rect.minY), radius: radius2, startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(-Double.pi / 2), clockwise: true)
    path.close()
    return path
}
