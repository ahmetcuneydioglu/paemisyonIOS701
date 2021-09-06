import UIKit

class ResultCell: UITableViewCell {

    @IBOutlet weak var rankLabel:UILabel!
    @IBOutlet weak var userImage:UIImageView!
    @IBOutlet weak var userName:UILabel!
    @IBOutlet weak var userRightAns:UILabel!
    @IBOutlet weak var userWrongAns:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.userImage.layer.borderColor = UIColor.lightGray.cgColor
        self.userImage.layer.borderWidth = 1
        self.userImage.layer.masksToBounds = true
        self.userImage.layer.cornerRadius = self.userImage.frame.size.height / 2
        
        self.userRightAns.layer.masksToBounds = true
        self.userRightAns.layer.cornerRadius = 15
        self.userWrongAns.layer.masksToBounds = true
        self.userWrongAns.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

