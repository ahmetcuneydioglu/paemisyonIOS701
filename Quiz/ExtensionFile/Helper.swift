import Foundation
import UIKit

struct API {
    let Name:String
    let ParamID:String
    var extraParam:String = ""
}

struct APINameID {
    let nameValue:String
    let idValue:String
}
extension UIViewController{
    func  GetAPIParam(name:String) -> API {
        
        switch name {
        case "category":
            return API.init(Name: "get_get_level1_by_maincategory", ParamID: "main_id")
        case "level1":
            return API.init(Name: "get_level2_by_level1", ParamID: "level1_id")
        case "level2":
            return API.init(Name: "get_level3_by_level2", ParamID: "level2_id")
        case "level3":
            return API.init(Name: "get_level4_by_level3", ParamID: "level3_id")
        case "level4":
            return API.init(Name: "get_level5_by_level4", ParamID: "level4_id")
        case "level5":
            return API.init(Name: "get_questions_by_all_level", ParamID: "level_id",extraParam: "level_name")
        default:
            return API.init(Name: "get_categories", ParamID: "id",extraParam: "visible_in")
        }
        
    }
    
    func NameValue(name:String)->APINameID{
        switch name {
        case "category":
            return APINameID.init(nameValue: "category_name", idValue: "")
        case "level1":
            return APINameID.init(nameValue: "name1", idValue: "")
        case "level2":
            return APINameID.init(nameValue: "name2", idValue: "")
        case "level3":
            return APINameID.init(nameValue: "name3", idValue: "")
        case "level4":
            return APINameID.init(nameValue: "name4", idValue: "")
        case "level5":
            return APINameID.init(nameValue: "name5", idValue: "")
        default:
            return APINameID.init(nameValue: "", idValue: "")
        }
    }
}


extension UILabel {
    func setFontSizeToFill() {
        let frameSize  = self.bounds.size
        guard frameSize.height>0 && frameSize.width>0 && self.text != nil else {return}

        var fontPoints = self.font.pointSize
        var fontSize   = self.text!.size(withAttributes: [NSAttributedString.Key.font: self.font.withSize(fontPoints)])
        var increment  = CGFloat(0)

        if fontSize.width > frameSize.width || fontSize.height > frameSize.height {
            increment = -1
        } else {
            increment = 1
        }

        while true {
            fontSize = self.text!.size(withAttributes: [NSAttributedString.Key.font: self.font.withSize(fontPoints+increment)])
            if increment < 0 {
                if fontSize.width < frameSize.width && fontSize.height < frameSize.height {
                    fontPoints += increment
                    break
                }
            } else {
                if fontSize.width > frameSize.width || fontSize.height > frameSize.height {
                    break
                }
            }
            fontPoints += increment
        }

        self.font = self.font.withSize(fontPoints)
    }
    
    func createDottedLine(width: CGFloat, color: CGColor) {
         let caShapeLayer = CAShapeLayer()
         caShapeLayer.strokeColor = color
         caShapeLayer.lineWidth = width
         caShapeLayer.lineDashPattern = [2,3]
         let cgPath = CGMutablePath()
         let cgPoint = [CGPoint(x: 0, y: 0), CGPoint(x: self.frame.width, y: 0)]
         cgPath.addLines(between: cgPoint)
         caShapeLayer.path = cgPath
         layer.addSublayer(caShapeLayer)
      }
    func createDottedBorder(cornerRadius: CGFloat) {
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = 1
        dashBorder.strokeColor = Apps.BASIC_COLOR_CGCOLOR
        dashBorder.lineDashPattern = [6, 5] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        layer.addSublayer(dashBorder)
    }
}
