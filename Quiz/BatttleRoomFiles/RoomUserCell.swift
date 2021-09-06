import UIKit

class RoomUserCell: UICollectionViewCell {
    
    @IBOutlet weak var userImage:UIImageView!
    @IBOutlet weak var userName:UILabel!
    
    var joinUser:JoinedUser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.userImage.layer.cornerRadius = self.userImage.frame.height / 2
        userImage.layer.borderWidth = 2
        userImage.layer.masksToBounds = true
    }
    
    func ConfigCell(){
        if  let currUser = self.joinUser{
                userImage.layer.borderColor = UIColor.white.cgColor
            if !currUser.userImage.isEmpty{
                userImage.loadImageUsingCache(withUrl: currUser.userImage)
            }else{
                userImage.image = UIImage(systemName: "person.fill")
            }
            userName.text = currUser.userName
            userName.textColor = UIColor.white
            userName.textColor = UIColor.white
        }else{
            userName.text = "???"
            userImage.image = UIImage(systemName: "person.fill")
            userName.textColor = UIColor.white
            userImage.layer.borderColor = UIColor.white.cgColor
        }
    }
}
