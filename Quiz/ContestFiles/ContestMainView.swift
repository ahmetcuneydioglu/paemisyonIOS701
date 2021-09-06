import UIKit
import AVFoundation

//structure for category
struct Contest {
    let id:String
    let name:String
    let start_date:String
    let end_date:String
    var description:String
    let image:String
    let entry:String
    let top_users:String
    let prize_status:String
    let date_created:String
    let participants:String
    }

struct ContestCopy {
    let id:String
    let name:String
    let descr:String
}

struct Points {
    let id:String
    let points:String
    let top_winner:String
}

class ContestMainView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var catetableView: UITableView!
    
    @IBOutlet weak var pointsTableView: UITableView!
    
    @IBOutlet var priceInfoView: UIView!
    
    @IBOutlet weak var user1Price: UILabel!
    @IBOutlet weak var user2Price: UILabel!
            
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    
    var points:[Points] = []
    var userWisePoints:[String] = []
    var catData:[Contest] = []
    var catDataCopy:[ContestCopy] = []
    var langList:[Language] = []
    var refreshController = UIRefreshControl()
    var config:SystemConfiguration?
    var apiName = "get_contest"
    var user:User!
    
    var tabSelect = ""
    var noData = ""
    var coins = ""
    var cellSizeX:CGFloat = 0
    var cellWidth: CGFloat = 0
    
    var contest_ID = 0
    var const_id = "0"
    var cc = 0
    var nm:[String] = []
    var coinVal:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        
        if isKeyPresentInUserDefaults(key: DEFAULT_SYS_CONFIG){
             config = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        }
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            let apiURL = "user_id=\(user.userID)"
            self.getAPIData(apiName: apiName, apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        refreshController.addTarget(self,action: #selector(self.RefreshDataOnPullDown),for: .valueChanged)
        catetableView.refreshControl = refreshController
        pointsTableView.refreshControl = refreshController
                
    }
    
    func ReLaodCategory() {
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            let apiURL = "user_id=\(user.userID)"
            self.getAPIData(apiName: apiName, apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    // refresh function
    @objc func RefreshDataOnPullDown(){
        if(Reachability.isConnectedToNetwork()){
            let apiURL = "user_id=\(user.userID)"
            self.getAPIData(apiName: apiName, apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    
    
     func showContestData(_ dataa: [[String:Any]]?){
         catData.removeAll()
         catDataCopy.removeAll() //copy for description text
         points.removeAll()
         if let data =  dataa {
             for val in data{
                 catData.append(Contest.init(id: "\(val["id"]!)", name: "\(val["name"]!)", start_date: "\(val["start_date"]!)", end_date: "\(val["end_date"]!)", description: "", image: "\(val["image"]!)", entry: "\(val["entry"]!)", top_users: "\(val["top_users"]!)", prize_status: "\(val["prize_status"]!)", date_created: "\(val["date_created"]!)", participants: "\(val["participants"]!)")) //- blank description at start
             
                catDataCopy.append(ContestCopy.init(id: "\(val["id"]!)", name: "\(val["name"]!)", descr: "\(val["description"]!)"))
                if let chkPoints = val["points"] as? [[String:Any]] {
                for p_chk in chkPoints{
                    points.append(Points.init(id: "\(val["id"]!)", points: "\(p_chk["points"]!)", top_winner: "\(p_chk["top_winner"]!)"))
                    }
                }
                print(points)
             }
         }
     }
     
    //load category data here
    func LoadData(jsonObj:NSDictionary){
        if tabSelect == "live_contest"{
            if let data = jsonObj.value(forKey: "live_contest") {
                guard let DATA = data as? [String:Any] else{
                    return
                }
                print(DATA)
                let status = DATA["error"]  as! Int
                
                if (status == 1) {
                DispatchQueue.main.async {
                    self.noData = DATA["message"] as! String
                }
            }else{
                if let data = DATA["data"] as? [[String:Any]] {
                    showContestData(data)
                }
            }
          }

        }else if tabSelect == "past_contest"{
            if let data = jsonObj.value(forKey: "past_contest") {
                guard let DATA = data as? [String:Any] else{
                    return
                }
                print(DATA)
                let status = DATA["error"]  as! Int
                
                if (status == 1) {
                DispatchQueue.main.async {
                    self.noData = DATA["message"] as! String
                }
            }else{
                if let data = DATA["data"] as? [[String:Any]] {
                    showContestData(data)
                }
            }
          }

        }else if tabSelect == "upcoming_contest"{
            if let data = jsonObj.value(forKey: "upcoming_contest") {
                guard let DATA = data as? [String:Any] else{
                    return
                }
                print(DATA)
                let status = DATA["error"]  as! Int
                
                if (status == 1) {
                DispatchQueue.main.async {
                  self.noData = DATA["message"] as! String
                }
            }else{
                if let data = DATA["data"] as? [[String:Any]] {
                    showContestData(data)
                }
            }
          }
        }
        
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.catetableView.reloadData()
                self.pointsTableView.reloadData()
                self.refreshController.endRefreshing()
            }
        });
    }
    
    @IBAction func closeView(_ sender: Any) {
        priceInfoView.removeFromSuperview()
    }
    @IBAction func showPriceInfo(_ sender: UIButton) {
        self.catetableView.reloadData()
                
        nm.removeAll()
        coinVal.removeAll()
        cc = 0
              
        const_id = String(sender.tag)
        //print(const_id)
        
        for i in points{
            print("test \(i)")
            if i.id == const_id {
                nm.append("Top User : \(i.top_winner)")
                coinVal.append("\(i.points) coins")
            }
        }
        
        priceInfoView.roundCorners(corners:[.topLeft,.topRight, .bottomLeft,.bottomRight], radius: 10)
        priceInfoView.center = priceInfoView.convert(self.view.center, from: priceInfoView)
        super.view.addSubview(priceInfoView)
        self.catetableView.reloadData()
        self.pointsTableView.reloadData()
    }
    @IBAction func showDescr(_ sender: UIButton) {
    let i = sender.tag
    let image = sender.currentImage
    if image == UIImage(named: "down"){
        self.catData[i].description = self.catDataCopy[i].descr
        self.catetableView.reloadData()
    }else if image == UIImage(named: "up") {
        self.catData[i].description = ""
        self.catetableView.reloadData()
    }
}

    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("count -- \(catData.count)")
         
        if self.pointsTableView == tableView{
            return nm.count
        }else{
            if catData.count == 0{
              let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
              noDataLabel.text          = noData
              noDataLabel.numberOfLines = 0
              noDataLabel.textColor     = Apps.BASIC_COLOR
              noDataLabel.textAlignment = .center
              noDataLabel.font = noDataLabel.font?.withSize(deviceStoryBoard == "Ipad" ? 25 : 15)
              tableView.backgroundView  = noDataLabel
              tableView.separatorStyle  = .none
          }
            return self.catData.count
        }
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.pointsTableView == tableView{
            guard let cell_points = self.pointsTableView.dequeueReusableCell(withIdentifier: "points", for: indexPath) as? TableViewCell  else {
                fatalError("The dequeued cell is not an instance.")
            }
            print(cc)
            if cc <= nm.count - 1{
                print("array \(nm) -- \(coinVal)")
                cell_points.topUserNum.text = nm[cc]
                cell_points.coinVal.text = coinVal[cc]
                cc = cc + 1
                print("cellForRowAt - pointsTblView")
            }
            
           return cell_points
         
        }else{
            let cellIdentifier = (self.catData[indexPath.row].description) == "" ? "cateCell": "cateCellDown"
            guard let cell = self.catetableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell  else {
                fatalError("The dequeued cell is not an instance.")
            }
            //set images for button in cell - to change on click later
            if cellIdentifier == "cateCell"{
                cell.descrBtn.setImage(UIImage(named: "down"), for: .normal)
            }else{
                cell.descrBtn.setImage(UIImage(named: "up"), for: .normal)
            }
                    
            cell.cateLbl.text = self.catData[indexPath.row].name
            cell.entryFeesVal.text = "\(self.catData[indexPath.row].entry) \(Apps.STR_COINS)"
            cell.endingOnVal.text = self.catData[indexPath.row].end_date
            cell.participantsVal.text = (self.catData[indexPath.row].participants)
            if (self.catData[indexPath.row].description) != "" {
                cell.detailDescription.text = (self.catData[indexPath.row].description)
            }
            
            cell.pointsBtn.tag = Int(catData[indexPath.row].id)!
            
            if(catData[indexPath.row]).image == "" {
                cell.cateImg.image = UIImage(named: "score") // set default image
            }else{
                DispatchQueue.main.async {
                    cell.cateImg.loadImageUsingCache(withUrl: self.catData[indexPath.row].image)// load image from url using cache
                }
            }
            cell.contestID.text = self.catData[indexPath.row].id
            cell.leaderboardBtn.tag = indexPath.row//Int(cell.contestID.text!)!
            cell.leaderboardBtn.addTarget(self, action: #selector(showLeaderboard(_:)), for: .touchUpInside)
            
            cell.descrBtn.tag = indexPath.row
            cell.descrBtn.addTarget(self, action: #selector(showDescr(_:)), for: .touchUpInside)
            cell.leaderboardBtn.layer.cornerRadius = 10
            cell.cellView.layer.masksToBounds = false
            cell.cellView.roundCorners(corners:[ .bottomLeft,.bottomRight], radius: 20)
            
            //chng captions and cell values according to tab selection
            if tabSelect == "live_contest"{
                cell.leaderboardBtn.alpha = 1
                cell.leaderboardBtn.setTitle(Apps.PLAY_BTN_TITLE, for: .normal)
                cell.endingOnKey.text = Apps.STR_ENDS_ON
            }else if tabSelect == "past_contest"{
                cell.leaderboardBtn.alpha = 1
                cell.leaderboardBtn.setTitle(Apps.LB_BTN_TITLE, for: .normal)
                cell.endingOnKey.text = Apps.STR_ENDING_ON
            }else if tabSelect == "upcoming_contest"{
                cell.leaderboardBtn.alpha = 0
                cell.participantsVal.alpha = 0
                cell.participantsKey.alpha = 0
              //  cell.separatorView.alpha = 0
                cell.endingOnKey.text = Apps.STR_STARTS_ON
                cell.endingOnVal.text = self.catData[indexPath.row].start_date
            }
            return cell
        }
    }
   
    @objc func showLeaderboard(_ button:UIButton){
                if tabSelect == "live_contest"{
                    //jump to play quiz
                    //check for available coins once, then deduct required coins to play contest
                    var mScore = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
                    print("data - \(mScore) -- self userscore--\(UserScore.self)--userdefault-- \((UserDefaults.standard.value(forKey:"UserScore") as? Data)!)")
                    if Int(self.catData[button.tag].entry)! > mScore.coins {
                        //show alert
                        ShowAlert(title: Apps.NO_COINS_TTL, message: Apps.NO_COINS_MSG)
                    }else{
                        var avail_coins = mScore.coins
                        avail_coins -= Int(self.catData[button.tag].entry)!
                        print(avail_coins)
                        //update coins
                        mScore.coins = avail_coins
                        Apps.COINS = String(avail_coins)
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(mScore),forKey: "UserScore")
                        //update coins to server
                        let duser =  try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
                        print(duser)
                        if duser.userID != ""{
                            if(Reachability.isConnectedToNetwork()){
                                let apiURL = "user_id=\(duser.userID)&coins=-\(Int(self.catData[button.tag].entry)!)"
                                self.getAPIData(apiName: "set_user_coin_score", apiURL: apiURL,completion: LoadResponse)
                            }
                        }
                        //goto play contest view
                        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "PlayContestView") as! PlayContestView
                        viewCont.contestID = Int(self.catData[button.tag].id)!
                        viewCont.contestNm = self.catData[button.tag].name
                        print(viewCont.contestNm)
                        self.navigationController?.pushViewController(viewCont, animated: true)
                    }
        }else if tabSelect == "past_contest"{
            //jump to Contest leaderboard
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ContestLeaderboard") as! ContestLeaderboard
            viewCont.contestID = Int(self.catData[button.tag].id)!
            self.navigationController?.pushViewController(viewCont, animated: true)
        }
    }
  
    //load response of updtFCMid data here
    func LoadResponse(jsonObj:NSDictionary){
        print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
        }else{
            // on success response do code here
            let msg = jsonObj.value(forKey: "message") as! String
            print("Response msg - \(msg)")
        }
    }
    
 }
