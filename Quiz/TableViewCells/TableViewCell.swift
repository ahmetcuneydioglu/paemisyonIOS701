import UIKit
import WebKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var cateLbl: UILabel!
    @IBOutlet weak var CateQue: UILabel!
    @IBOutlet weak var cateImg: UIImageView!
    
    @IBOutlet weak var sCateLbl: UILabel!
    @IBOutlet weak var sCateQue: UILabel!
    @IBOutlet weak var sCateImg: UIImageView!
    
    @IBOutlet weak var lvlLbl: UILabel!
    @IBOutlet weak var qNoLbl: UILabel!
    @IBOutlet weak var lockImg: UIImageView!
    
    @IBOutlet weak var cellView1: UIView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cellView2: UIView!
    @IBOutlet weak var leadrView: UIView!
    
    @IBOutlet weak var contestPointsView: UIView!
    
    @IBOutlet weak var scorLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var srLbl: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var imgView: UIView!
    
    @IBOutlet weak var bookImg: UIImageView!
    @IBOutlet weak var bookView: UIView!
    @IBOutlet weak var qstn: UILabel!
    @IBOutlet weak var ansr: UILabel!
    
    @IBOutlet weak var label1Char: UILabel!
    
    //contest
    @IBOutlet weak var priceVal: UILabel!
    @IBOutlet weak var entryFeesVal: UILabel!
    @IBOutlet weak var endingOnKey: UILabel!
    @IBOutlet weak var endingOnVal: UILabel!
    @IBOutlet weak var participantsKey: UILabel!
    @IBOutlet weak var participantsVal: UILabel!
    @IBOutlet weak var leaderboardBtn: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var descrBtn: UIButton!
    
    @IBOutlet weak var detailDescription: UITextView!
    
    @IBOutlet weak var pointsBtn: UIButton!
    //contest
    @IBOutlet weak var contestID: UILabel!
    //PointsCell
    @IBOutlet weak var topUserNum: UILabel!
    @IBOutlet weak var coinVal: UILabel!
        
    @IBOutlet weak var gradientLine: GradientButton!
    
    @IBOutlet weak var tfbtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
   
}
