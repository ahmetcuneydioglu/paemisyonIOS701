import UIKit

class BattleUserScoreCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView:UIView!
    @IBOutlet weak var userImg:UIImageView!
    @IBOutlet weak var userName:UILabel!
    @IBOutlet weak var userRight:UILabel!
    @IBOutlet weak var userWrong:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userImg.layer.cornerRadius = self.userImg.frame.height / 2
        self.userRight.layer.cornerRadius = self.userRight.frame.height / 2
        self.userRight.layer.masksToBounds = true
        self.userWrong.layer.cornerRadius = self.userWrong.frame.height / 2
        self.userWrong.layer.masksToBounds = true
    }
    
}
