import UIKit
import FirebaseDatabase

class BattleRoomResult: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var mainView:UIView!
    @IBOutlet weak var topView:UIView!
    @IBOutlet weak var backButton:UIButton!
        
    var joinedUsers:[JoinedUser] = []
    var roomInfo:RoomDetails?
    var roomType = "private"
    var roomCode = "00000"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainView.layer.cornerRadius = 13
        self.joinedUsers.sort(by: { Int($0.rightAns)! > Int($1.rightAns)! })
        self.tableView.reloadData()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.CompleteBattle()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func BacktoHomeAction(_ sender: Any) {
        self.CompleteBattle()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func DesignImage(images:UIImageView...){
        for image in images{
            image.layer.masksToBounds = true
            image.layer.cornerRadius = image.frame.height / 2
        }
    }
    
    func DesignLabel(labels:UILabel...){
        for label in labels{
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 4
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundColor = .clear
        //print("total joinedUser -- \(joinedUsers.count)")
         return joinedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
        
        let user = self.joinedUsers[indexPath.row]
        cell.userName.text = user.userName
        cell.rankLabel.text = "\(indexPath.row + 1)"
        cell.userRightAns.text = user.rightAns
        cell.userWrongAns.text = user.wrongAns
        if user.userImage.isEmpty{
            cell.userImage.image = UIImage(systemName: "person.fill")
        }else{
            DispatchQueue.main.async {
                cell.userImage.loadImageUsingCache(withUrl: user.userImage)
            }
        }
        cell.layer.cornerRadius = 20
        return cell
    }
    
    func CompleteBattle(){
        let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        let roomVal = Database.database().reference().child("MultiplayerRoom").child(roomCode)
        roomVal.observeSingleEvent(of: .value, with: { (snapshot) in
             if let data = snapshot.value as? [String:Any]{
                print(data)
                let authID = data["authId"] as! String
                print(authID)
                if authID == user.UID {
                    roomVal.removeValue()
                }
             }
        })
    }
}
