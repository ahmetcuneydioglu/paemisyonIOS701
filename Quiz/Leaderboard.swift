import UIKit

struct Leader{
    let rank:String
    let name:String
    let image:String
    let score:String
    let userID:String
}

class Leaderboard: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
        
    @IBOutlet var usr1Lbl: UILabel!
    @IBOutlet var usr2Lbl: UILabel!
    @IBOutlet var usr3Lbl: UILabel!
    
    @IBOutlet var score1Lbl: UILabel!
    @IBOutlet var score2Lbl: UILabel!
    @IBOutlet var score3Lbl: UILabel!
    
    @IBOutlet weak var user1OutLine: UIView!
    @IBOutlet weak var user2OutLine: UIView!
    @IBOutlet weak var user3OutLine: UIView!
    
    @IBOutlet var usr1: UIImageView!
    @IBOutlet var usr2: UIImageView!
    @IBOutlet var usr3: UIImageView!
        
    @IBOutlet weak var user2View: UIView!
    @IBOutlet weak var user1View: UIView!
    @IBOutlet weak var user3View: UIView!
    
    @IBOutlet weak var buttonAll: UIButton!
        
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var LeaderData:[Leader] = []
    var thisUser:User!
    var ttlCount = 0
    var offset = 0
    var selection = Apps.DAILY
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        //set text color for both the states
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Apps.BASIC_COLOR], for: .selected)
        segmentControl.backgroundColor = Apps.BASIC_COLOR
        if deviceStoryBoard == "Ipad"{
            segmentControl.frame = CGRect(x: segmentControl.frame.origin.x, y: segmentControl.frame.origin.y, width: segmentControl.frame.width, height: segmentControl.frame.height + 10)
        }
        
        usr1.layer.cornerRadius = usr1.frame.height/2
        usr1.layer.borderWidth = 3
        usr1.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
        
        usr2.layer.cornerRadius = usr2.frame.height/2
        usr2.layer.borderWidth = 3
        usr2.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
        
        usr3.layer.cornerRadius = usr3.frame.height/2
        usr3.layer.borderWidth = 3
        usr3.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
        
        user1OutLine.layer.cornerRadius = user1OutLine.frame.height/2
        user1OutLine.layer.borderWidth = 4
        user1OutLine.layer.borderColor = UIColor.white.cgColor
        
        user2OutLine.layer.cornerRadius = user2OutLine.frame.height/2
        user2OutLine.layer.borderWidth = 4
        user2OutLine.layer.borderColor = UIColor.white.cgColor
        
        user3OutLine.layer.cornerRadius = user3OutLine.frame.height/2
        user3OutLine.layer.borderWidth = 4
        user3OutLine.layer.borderColor = UIColor.white.cgColor
        
        thisUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        print(thisUser!)
        
        getLeaders(sel: Apps.DAILY)//get data from server
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl){
        if sender.selectedSegmentIndex == 0 { //today
            LeaderData.removeAll()
            offset = 0 //reset offset value
            selection = Apps.DAILY
            getLeaders(sel: Apps.DAILY)
        }else if sender.selectedSegmentIndex == 1 { //month
            LeaderData.removeAll()
            offset = 0 //reset offset value
            selection = Apps.MONTHLY
            getLeaders(sel: Apps.MONTHLY)
        }else if sender.selectedSegmentIndex == 2 { //all
            LeaderData.removeAll()
            offset = 0 //reset offset value
            selection = Apps.ALL
            getLeaders(sel: Apps.ALL)
        }
    }
    
    //get data from server
    func getLeaders(sel : String){
        if(Reachability.isConnectedToNetwork()){
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd"
            if (sel == Apps.DAILY) { //daily
                let apiURL = "from=\(dateFormatterGet.string(from: Date()))&to=\(dateFormatterGet.string(from: Date()))"
               // print(apiURL)
                self.getAPIData(apiName: "get_datewise_leaderboard", apiURL: apiURL,completion: LoadData)
            }
            if (sel == Apps.MONTHLY){ //monthly
                
                var apiURL = "date=\(dateFormatterGet.string(from: Date().startOfMonth()))"
                if offset < ttlCount {
                    apiURL += "&offset=\(offset)"
                }
                self.getAPIData(apiName: "get_monthly_leaderboard", apiURL: apiURL,completion: LoadData)
            }
            if(sel == Apps.ALL){ //all
                var apiURL = ""
                if offset < ttlCount {
                    apiURL = "offset=\(offset)"
                }
                self.getAPIData(apiName: "get_global_leaderboard", apiURL: apiURL,completion: LoadData)
            }
        }
        else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    
    //load data here
    func LoadData(jsonObj:NSDictionary){
        print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        //print(status)
        if (status == "true") {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    if jsonObj.value(forKey: "message")! as! String == ""{
                        self.ShowAlert(title: Apps.ERROR, message: Apps.NO_DATA )
                    }else{
                        self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                    }
                    self.user1View.isHidden = true
                    self.user2View.isHidden = true
                    self.user3View.isHidden = true
                })
            }
        }else{
            DispatchQueue.main.async {
                self.user1View.isHidden = false
                self.user2View.isHidden = false
                self.user3View.isHidden = false
            }
            let strCount: String = jsonObj.value(forKey: "total") as! String //returns total count of records from response
            ttlCount = Int(strCount)! //total number of records according to filter
            
            //get data
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    LeaderData.append(Leader.init(rank: "\(val["user_rank"]!)", name: "\(val["name"]!)", image: "\(val["profile"]!)", score: "\(val["score"]!)", userID: "\(val["user_id"]!)"))
                }
                offset += data.count //updated every time
                print("leader data count \(LeaderData.count)")
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
                //set top 3 rank data here
                 
                //hide views if in Daily leaderboard just contain 1 or 2 entries, otherwise show all data in default case.
                switch self.LeaderData.count{
                case 0:
                    print("total count is -> \(self.LeaderData.count)")
                case 1:
                    if(!self.LeaderData[0].image.isEmpty){
                        self.usr1.loadImageUsingCache(withUrl: self.LeaderData[0].image)
                    }
                    if (!self.LeaderData[0].name.isEmpty) && (!self.LeaderData[0].score.isEmpty) {
                        self.usr1Lbl.text = "\(self.LeaderData[0].name)"
                        self.score1Lbl.text = self.convertScoreString(Int(self.LeaderData[0].score)!)
                    }
                    else{
                        self.user1View.isHidden = true
                    }
                    //if there is no other users data there then just hide that view.!
                    self.user2View.isHidden = true
                    self.user3View.isHidden = true
                   
                case 2:
                    //user 1
                    if(!self.LeaderData[0].image.isEmpty){
                        self.usr1.loadImageUsingCache(withUrl: self.LeaderData[0].image)
                    }
                    if (!self.LeaderData[0].name.isEmpty) && (!self.LeaderData[0].score.isEmpty) {
                        self.usr1Lbl.text = "\(self.LeaderData[0].name)"
                        self.score1Lbl.text = self.convertScoreString(Int(self.LeaderData[0].score)!)
                        if self.user1View.isHidden == true{
                            self.user1View.isHidden = false
                        }
                    }
                    else{
                        self.user1View.isHidden = true
                    }
                    //user 2
                    if(!self.LeaderData[1].image.isEmpty){
                        self.usr2.loadImageUsingCache(withUrl: self.LeaderData[1].image)
                    }
                    if (!self.LeaderData[1].name.isEmpty) && (!self.LeaderData[1].score.isEmpty) {
                        self.usr2Lbl.text = "\(self.LeaderData[1].name)"
                        self.score2Lbl.text = self.convertScoreString(Int(self.LeaderData[1].score)!)
                        if self.user2View.isHidden == true{
                            self.user2View.isHidden = false
                        }
                    }
                    else{
                        self.user2View.isHidden = true
                    }
                    //if there is no other users data there then just hide that view.!
                    self.user3View.isHidden = true
                     
                case 3:
                    //user 1
                    if(!self.LeaderData[0].image.isEmpty){
                        self.usr1.loadImageUsingCache(withUrl: self.LeaderData[0].image)
                    }
                    if (!self.LeaderData[0].name.isEmpty) && (!self.LeaderData[0].score.isEmpty) {
                        self.usr1Lbl.text = "\(self.LeaderData[0].name)"
                        self.score1Lbl.text = self.convertScoreString(Int(self.LeaderData[0].score)!)
                        if self.user1View.isHidden == true{
                            self.user1View.isHidden = false
                        }
                    } else{
                        self.user1View.isHidden = true
                    }
                    //user 2
                    if(!self.LeaderData[1].image.isEmpty){
                        self.usr2.loadImageUsingCache(withUrl: self.LeaderData[1].image)
                    }
                    if (!self.LeaderData[1].name.isEmpty) && (!self.LeaderData[1].score.isEmpty) {
                        self.usr2Lbl.text = "\(self.LeaderData[1].name)"
                        self.score2Lbl.text = self.convertScoreString(Int(self.LeaderData[1].score)!)
                        if self.user2View.isHidden == true{
                            self.user2View.isHidden = false
                        }
                    }else{
                        self.user2View.isHidden = true
                    }
                    //user 3
                    if(!self.LeaderData[2].image.isEmpty){
                        self.usr3.loadImageUsingCache(withUrl: self.LeaderData[2].image)
                    }
                    if (!self.LeaderData[2].name.isEmpty) && (!self.LeaderData[2].score.isEmpty) {
                        self.usr3Lbl.text = "\(self.LeaderData[2].name)"
                        self.score3Lbl.text = self.convertScoreString(Int(self.LeaderData[2].score)!)
                        if self.user3View.isHidden == true{
                            self.user3View.isHidden = false
                        }
                    }
                    else{
                        self.user3View.isHidden = true
                    }
                default:
                    //executed if LeaderData get more than 3 records
                    self.showALLinLeaderboard()
                }
                
                self.DesignImageView(self.usr1,self.usr2,self.usr3)
                //reload data after getting it from server
                self.tableView.reloadData()
                
                //set bottom view in every case
                self.AddUsertoBottom()
            }
        });
    }
    
    func convertScoreString(_ score: Int) -> String{
        var numberString = ""
        if (fabsf(Float(score) / 1000000) > 1) {
            numberString = "\(Float(score) / 1000000)M"

        } else if (fabsf(Float(score) / 1000) > 1) {
            numberString = "\(Float(score) / 1000)K"
        } else {
            numberString = String(score)
        }
       // print(numberString)
        return numberString
    }
    
    
    func showALLinLeaderboard() {
        
        if(!self.LeaderData[0].image.isEmpty){
            self.usr1.loadImageUsingCache(withUrl: self.LeaderData[0].image)
        }
        if(!self.LeaderData[1].image.isEmpty){
            self.usr2.loadImageUsingCache(withUrl: self.LeaderData[1].image)
        }
        if(!self.LeaderData[2].image.isEmpty){
            self.usr3.loadImageUsingCache(withUrl: self.LeaderData[2].image)
        }
        
        self.usr1Lbl.text = "\(self.LeaderData[0].name)"
        self.usr2Lbl.text = "\(self.LeaderData[1].name)"
        self.usr3Lbl.text = "\(self.LeaderData[2].name)"
        
        self.score1Lbl.text = self.convertScoreString(Int(self.LeaderData[0].score)!)
        self.score2Lbl.text = self.convertScoreString(Int(self.LeaderData[1].score)!)
        self.score3Lbl.text = self.convertScoreString(Int(self.LeaderData[2].score)!)
        
        //show all 3 views incase hidden in previous cases
        self.user1View.isHidden = false
        self.user2View.isHidden = false
        self.user3View.isHidden = false
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.LeaderData.removeAll()
        self.navigationController?.popViewController(animated: true)
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return self.LeaderData.count - 3
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cellIdentifier = "boardCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell  else {
            fatalError("The dequeued cell is not an instance.")
        }
        
        let rowIndex = indexPath.row + 3
        if rowIndex == (LeaderData.count - 8) {
           
        if offset < ttlCount {
            print(selection)
            getLeaders(sel:selection)
             do { //delay to load appending data
                 sleep(2)
             }
          }
        }
        
        cell.srLbl.text = "\(LeaderData[rowIndex].rank)"
        cell.scorLbl.text = self.convertScoreString(Int(self.LeaderData[rowIndex].score)!)
        cell.nameLbl.text = "\(LeaderData[rowIndex].name)"
        
        cell.scorLbl.roundCorners(corners: [ .bottomLeft, .topLeft], radius: 10)
        cell.scorLbl.textAlignment = NSTextAlignment.center
        cell.srLbl.roundCorners(corners: [ .bottomRight, .topRight], radius: 10)
        
        if(self.LeaderData[rowIndex].image.isEmpty) {
            cell.userImg.image = UIImage(named: "AppIcon") // set default image
        }else{
            DispatchQueue.main.async {
                cell.userImg.loadImageUsingCache(withUrl: self.LeaderData[rowIndex].image)// load image from url using cache
            }
        }
        
        self.DesignImageView(cell.userImg)
        cell.imgView.layer.cornerRadius = cell.imgView.frame.width / 2
        cell.imgView.layer.masksToBounds = false
        cell.imgView.clipsToBounds = true
        cell.imgView.layer.borderWidth = 2
        cell.imgView.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    //check user rank is it visible to view without scroll
    func AddUsertoBottom(){        
        //if you change height below chng the same in temp.frame.height == 60
        let bottomView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 60, width: self.tableView.frame.width, height: 60))
        let this = LeaderData.filter{$0.userID == thisUser.userID}
        
        if !this.isEmpty {
            let rankLabel = UILabel(frame: CGRect(x: 0, y: 10, width: 45, height: 35))
            rankLabel.text = this[0].rank
            rankLabel.textColor = UIColor.white
            rankLabel.textAlignment = NSTextAlignment.center
            rankLabel.roundCorners(corners: [ .bottomRight, .topRight], radius: 15)
            bottomView.addSubview(rankLabel)
            
            let imageView = UIImageView(frame: CGRect(x: 50, y: 5, width: 40, height: 40))
            if this[0].image != ""{
                imageView.loadImageUsingCache(withUrl: this[0].image)
            }else{
                imageView.image = UIImage(named: "AppIcon")
            }
            imageView.layer.cornerRadius = 40 / 2
            imageView.layer.masksToBounds = true
            imageView.layer.borderColor = UIColor.white.cgColor
            imageView.layer.borderWidth = 1.5
            bottomView.addSubview(imageView)
            
            var nameLabel = UILabel()
            if deviceStoryBoard == "Ipad" {
                nameLabel = UILabel(frame: CGRect(x: 105, y: 10, width: 400,height: 30))
                nameLabel.font = nameLabel.font?.withSize(CGFloat(20))
                nameLabel.adjustsFontSizeToFitWidth = true;
            }else{
                nameLabel = UILabel(frame: CGRect(x: 105, y: 5, width: self.view.frame.width - 200, height: 45))
            }
            nameLabel.text = this[0].name
            nameLabel.textAlignment = .left
            nameLabel.numberOfLines = 0
            nameLabel.textAlignment = .justified
            nameLabel.lineBreakMode = .byWordWrapping
            nameLabel.textColor = UIColor.white
            bottomView.addSubview(nameLabel)
            
            let scoreLabel = UILabel(frame: CGRect(x: self.view.frame.width - 60, y: 10, width: 60, height: 35))
            scoreLabel.text = self.convertScoreString(Int(this[0].score)!)
            scoreLabel.textColor = UIColor.white
            scoreLabel.adjustsFontSizeToFitWidth = true
            scoreLabel.textAlignment = .center
            scoreLabel.roundCorners(corners: [.topLeft, .bottomLeft], radius: 10)
            scoreLabel.layer.masksToBounds = true
            bottomView.addSubview(scoreLabel)
            bottomView.setGradientLayer(UIColor.init(named: "blue1") ?? UIColor.blue,UIColor.init(named: "blue2") ?? UIColor.cyan)
            bottomView.roundCorners(corners: [.topLeft,.topRight], radius: 10)
            self.view.addSubview(bottomView)
        }else{
            //remove subview
            for temp in self.view.subviews {
                if temp.frame.height == 60  {
                    temp.removeFromSuperview ()
                }
            }
            print(self.view.subviews)
        }
    }
}
