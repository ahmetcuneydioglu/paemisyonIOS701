import Foundation
import UIKit

public class CircularProgressBar: CALayer {
    
    private var circularPath: UIBezierPath!
    public var innerTrackShapeLayer: CAShapeLayer!
    public var outerTrackShapeLayer: CAShapeLayer!
    private let rotateTransformation = CATransform3DMakeRotation(-.pi / 2, 0, 0, 1)
    private var completedLabel: UILabel!
    public var progressLabel: UILabel!
    public var isUsingAnimation: Bool!
    public var progress: CGFloat = 0 {
        didSet {
            progressLabel.text = "\(Int(progress))"
            innerTrackShapeLayer.strokeEnd = progress / Apps.QUIZ_PLAY_TIME
            if progress > Apps.QUIZ_PLAY_TIME {
                progressLabel.text = "\(Apps.QUIZ_PLAY_TIME)"
            }
        }
    }
    
    var progValue:CGFloat = 0
    public var progressManual: CGFloat = 0 {
        didSet {
            progressLabel.text = "\(Int(progressManual))%"
            innerTrackShapeLayer.strokeEnd = progressManual / progValue
            if progressManual > progValue {
                progressLabel.text = "\(progValue)%"
            }
        }
    }
    public var progressValue: CGFloat = 0 {
           didSet {
               innerTrackShapeLayer.strokeEnd = progressValue / 100
           }
       }
    
    public init(radius: CGFloat, position: CGPoint, innerTrackColor: UIColor, outerTrackColor: UIColor, lineWidth: CGFloat) {
        super.init()
        
        circularPath = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        outerTrackShapeLayer = CAShapeLayer()
        outerTrackShapeLayer.path = circularPath.cgPath
        outerTrackShapeLayer.position = position
        outerTrackShapeLayer.strokeColor = outerTrackColor.cgColor
        outerTrackShapeLayer.fillColor = UIColor.clear.cgColor
        outerTrackShapeLayer.lineWidth = lineWidth
        outerTrackShapeLayer.strokeEnd = 1
        outerTrackShapeLayer.transform = rotateTransformation
        addSublayer(outerTrackShapeLayer)
        
        innerTrackShapeLayer = CAShapeLayer()
        innerTrackShapeLayer.strokeColor = innerTrackColor.cgColor
        innerTrackShapeLayer.position = position
        innerTrackShapeLayer.strokeEnd = progress
        innerTrackShapeLayer.lineWidth = lineWidth
        innerTrackShapeLayer.fillColor = UIColor.clear.cgColor
        innerTrackShapeLayer.path = circularPath.cgPath
        innerTrackShapeLayer.transform = rotateTransformation
        addSublayer(innerTrackShapeLayer)
        
        progressLabel = UILabel()
        let size = CGSize(width: radius, height: radius)
        let origin = CGPoint(x: position.x, y: position.y)
        progressLabel.frame = CGRect(origin: origin, size: size)
        progressLabel.center = position
        progressLabel.center.y = position.y - 1
        progressLabel.font = UIFont.boldSystemFont(ofSize: radius * 0.27)
        progressLabel.text = "0"
        progressLabel.font = progressLabel.font.withSize(12)
        progressLabel.textColor = Apps.BASIC_COLOR //UIColor.white//
        progressLabel.textAlignment = .center
        insertSublayer(progressLabel.layer, at: 0)
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: position.x , y: position.y), radius: CGFloat(radius), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor =  Apps.defaultPulseFillColor.cgColor
        insertSublayer(shapeLayer, at: 0)
    }
    
    public init(radius: CGFloat, position: CGPoint, innerTrackColor: UIColor, outerTrackColor: UIColor, lineWidth: CGFloat,progValue:CGFloat) {
        super.init()
        
        self.progValue = progValue
        circularPath = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        outerTrackShapeLayer = CAShapeLayer()
        outerTrackShapeLayer.path = circularPath.cgPath
        outerTrackShapeLayer.position = position
        outerTrackShapeLayer.strokeColor = outerTrackColor.cgColor
        outerTrackShapeLayer.fillColor = UIColor.clear.cgColor
        outerTrackShapeLayer.lineWidth = lineWidth
        outerTrackShapeLayer.strokeEnd = 1
        outerTrackShapeLayer.transform = rotateTransformation
        addSublayer(outerTrackShapeLayer)
        
        innerTrackShapeLayer = CAShapeLayer()
        innerTrackShapeLayer.strokeColor = innerTrackColor.cgColor
        innerTrackShapeLayer.position = position
        innerTrackShapeLayer.strokeEnd = progressManual
        innerTrackShapeLayer.lineWidth = lineWidth
        innerTrackShapeLayer.fillColor = UIColor.clear.cgColor
        innerTrackShapeLayer.path = circularPath.cgPath
        innerTrackShapeLayer.transform = rotateTransformation
        addSublayer(innerTrackShapeLayer)
        
        progressLabel = UILabel()
        let size = CGSize(width: radius, height: radius)
        let origin = CGPoint(x: position.x, y: position.y)
        progressLabel.frame = CGRect(origin: origin, size: size)
        progressLabel.center = position
        progressLabel.center.y = position.y - 1
        progressLabel.font = UIFont.boldSystemFont(ofSize: radius * 0.27)
        progressLabel.text = "0"
        progressLabel.font = progressLabel.font.withSize(12)
        progressLabel.textColor = Apps.BASIC_COLOR //UIColor.white//
        progressLabel.textAlignment = .center
        insertSublayer(progressLabel.layer, at: 0)
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: position.x , y: position.y), radius: CGFloat(radius), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor =  Apps.defaultPulseFillColor.cgColor
        insertSublayer(shapeLayer, at: 0)
    }
    
    public init(radius: CGFloat, position: CGPoint, innerTrackColor: UIColor, outerTrackColor: UIColor, fillColor: UIColor , lineWidth: CGFloat) {
           super.init()
           
           circularPath = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
           outerTrackShapeLayer = CAShapeLayer()
           outerTrackShapeLayer.path = circularPath.cgPath
           outerTrackShapeLayer.position = position
           outerTrackShapeLayer.strokeColor = outerTrackColor.cgColor
           outerTrackShapeLayer.fillColor = UIColor.clear.cgColor
           outerTrackShapeLayer.lineWidth = lineWidth
           outerTrackShapeLayer.strokeEnd = 1
           outerTrackShapeLayer.transform = rotateTransformation
           addSublayer(outerTrackShapeLayer)
           
           innerTrackShapeLayer = CAShapeLayer()
           innerTrackShapeLayer.strokeColor = innerTrackColor.cgColor
           innerTrackShapeLayer.position = position
           innerTrackShapeLayer.strokeEnd = progressManual
           innerTrackShapeLayer.lineWidth = lineWidth
           innerTrackShapeLayer.fillColor = UIColor.clear.cgColor
           innerTrackShapeLayer.path = circularPath.cgPath
           innerTrackShapeLayer.transform = rotateTransformation
           addSublayer(innerTrackShapeLayer)
           
           progressLabel = UILabel()
           let size = CGSize(width: radius, height: radius)
           let origin = CGPoint(x: position.x, y: position.y)
           progressLabel.frame = CGRect(origin: origin, size: size)
           progressLabel.center = position
           progressLabel.center.y = position.y - 1
           progressLabel.font = UIFont.boldSystemFont(ofSize: radius * 0.27)
           //progressLabel.text = "0"
           progressLabel.font = progressLabel.font.withSize(12)
           progressLabel.textColor = Apps.BASIC_COLOR
           progressLabel.textAlignment = .center
           insertSublayer(progressLabel.layer, at: 0)
           
           let circlePath = UIBezierPath(arcCenter: CGPoint(x: position.x , y: position.y), radius: CGFloat(radius), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
           let shapeLayer = CAShapeLayer()
           shapeLayer.path = circlePath.cgPath
           shapeLayer.fillColor = fillColor.cgColor
           insertSublayer(shapeLayer, at: 0)
       }
    
    public override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}









