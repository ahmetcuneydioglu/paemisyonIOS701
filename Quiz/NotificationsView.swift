import UIKit

class NotificationsView : UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet var tableView: UITableView!

    var NotificationList: [Notifications] = []
    
     var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //clear notification badges
        if Apps.badgeCount > 0 {
           Apps.badgeCount = 0
           UserDefaults.standard.set(Apps.badgeCount, forKey: "badgeCount")
        }

        
        if (UserDefaults.standard.value(forKey: "notification") != nil){
            NotificationList = try! PropertyListDecoder().decode([Notifications].self,from:(UserDefaults.standard.value(forKey: "notification") as? Data)!)
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            self.navigationController?.popToViewController( (self.navigationController?.viewControllers[1]) as! HomeScreenController, animated: true)
        }
    }
        
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         
        if NotificationList.count == 0{
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = Apps.NO_NOTIFICATION
            noDataLabel.textColor     = Apps.BASIC_COLOR
            noDataLabel.textAlignment = .center
            noDataLabel.font = noDataLabel.font?.withSize(deviceStoryBoard == "Ipad" ? 25 : 15)
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        print(NotificationList.count)
        return NotificationList.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cellIdentifier = NotificationList[indexPath.row].img != "" ? "NotifyCell" : "NotifyCellNoImage"
                
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell  else {
            fatalError("The dequeued cell is not an instance.")
        }
        
        cell.qstn.text = NotificationList[indexPath.row].title
        //show 2 characters of Title at left side of title and message here
           let x = cell.qstn.text!.prefix(2)
            cell.label1Char.text = String(x)
            //print(x)
            cell.label1Char.layer.masksToBounds = true
            cell.label1Char.layer.cornerRadius = 5
            cell.label1Char.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
            cell.label1Char.layer.borderWidth = 1
            cell.label1Char.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.3, radius: 20, scale: true)
        //}
        cell.ansr.text = NotificationList[indexPath.row].msg
        if(NotificationList[indexPath.row].img != "") {
            let url: String =  self.NotificationList[indexPath.row].img
                      DispatchQueue.main.async {
                          cell.bookImg.loadImageUsingCache(withUrl: url)
                      }
            }
        
        cell.gradientLine.layer.cornerRadius = 5
        
        checkForValues(NotificationList.count)
        cell.bookView.SetShadow()
        cell.bookView.layer.cornerRadius = 10
        cell.bookView.addBottomBorderWithGradientColor(startColor: Apps.arrColors1[indexPath.row]!, endColor: Apps.arrColors2[indexPath.row]!, width: 3, cornerRadius: cell.bookView.layer.cornerRadius)
        
        return cell
    }
    //set height for specific cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = CGFloat()

        if NotificationList[indexPath.row].img != ""{
            height = 150
        }else{
            height = 100
        }
        if NotificationList[indexPath.row].msg.count <= 35 {
           height = height + 10
       } else if NotificationList[indexPath.row].msg.count <= 80 {
           height = height + 40
       } else if NotificationList[indexPath.row].msg.count <= 155 {
           height = height + 80
       } else if NotificationList[indexPath.row].msg.count > 155 {
           height = height + 200
       }        
        return height
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
}
