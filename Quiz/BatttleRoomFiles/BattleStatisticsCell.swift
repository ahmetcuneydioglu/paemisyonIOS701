import UIKit

class BattleStatisticsCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var opponentImage: UIImageView!
    @IBOutlet weak var opponentName: UILabel!
    @IBOutlet weak var matchStatusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
