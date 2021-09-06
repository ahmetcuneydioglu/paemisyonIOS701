import UIKit

struct LeaderC{
    let name:String
    let image:String
    let score:String
    let userID:String
    let userRank:String
}

class ContestLeaderboard: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var selectionOptView: UIView!
  
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
    
    @IBOutlet weak var titlesLbl: UILabel!
    
    @IBOutlet weak var bannerView: UIView!
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var LeaderData:[LeaderC] = []
    var thisUser:User!
    var ttlCount = 0
    var offset = 0
    
    var contestID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        usr1.layer.cornerRadius = usr1.frame.height/2
        usr1.layer.borderWidth = 3
        usr1.layer.borderColor = UIColor.clear.cgColor
        
        usr2.layer.cornerRadius = usr2.frame.height/2
        usr2.layer.borderWidth = 3
        usr2.layer.borderColor = UIColor.clear.cgColor
        
        usr3.layer.cornerRadius = usr3.frame.height/2
        usr3.layer.borderWidth = 3
        usr3.layer.borderColor = UIColor.clear.cgColor
        
        titlesLbl.layer.cornerRadius = 10
        titlesLbl.clipsToBounds = true
        
        user1OutLine.layer.cornerRadius = user1OutLine.frame.height/2
        user1OutLine.layer.masksToBounds = false
        user1OutLine.clipsToBounds = true
        user1OutLine.layer.borderWidth = 4
        user1OutLine.layer.borderColor = UIColor.white.cgColor
        
        user2OutLine.layer.cornerRadius = user2OutLine.frame.height/2
        user2OutLine.layer.masksToBounds = false
        user2OutLine.clipsToBounds = true
        user2OutLine.layer.borderWidth = 4
        user2OutLine.layer.borderColor = UIColor.white.cgColor
        
        user3OutLine.layer.cornerRadius = user3OutLine.frame.height/2
        user1OutLine.layer.masksToBounds = false
        user1OutLine.clipsToBounds = true
        user3OutLine.layer.borderWidth = 4
        user3OutLine.layer.borderColor = UIColor.white.cgColor
        
        thisUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        //print(thisUser)
        
        getLeaders()//get data from server
    }
    
    //get data from server
    func getLeaders(){
        if(Reachability.isConnectedToNetwork()){
            let apiURL = "contest_id=\(contestID)&user_id=\(thisUser.userID)"
                print(apiURL)
                self.getAPIData(apiName: "get_contest_leaderboard", apiURL: apiURL,completion: LoadData)
        }
        else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    //load data here
    func LoadData(jsonObj:NSDictionary){
        print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        print(status)
        if (status == "true") {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    print("Data Not Found !!!")
                    if jsonObj.value(forKey: "message")! as! String == "" {
                        self.ShowAlert(title: Apps.ERROR, message: Apps.NO_DATA )
                    }else{
                        self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                    }
                })
            }            
        }else{
            //get data for category
            self.LeaderData.removeAll()
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    LeaderData.append(LeaderC.init(name: "\(val["name"]!)", image: "\(val["profile"]!)", score: "\(val["score"]!)", userID: "\(val["user_id"]!)", userRank: "\(val["user_rank"]!)"))
                }
                offset += data.count //updated every time
                print("leader data \(data)")
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
                        self.score1Lbl.text = "\(self.LeaderData[0].score)"
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
                        self.score1Lbl.text = "\(self.LeaderData[0].score)"
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
                        self.score2Lbl.text = "\(self.LeaderData[1].score)"
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
                        self.score1Lbl.text = "\(self.LeaderData[0].score)"
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
                        self.score2Lbl.text = "\(self.LeaderData[1].score)"
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
                        self.score3Lbl.text = "\(self.LeaderData[2].score)"
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
            }
        });
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
        
        
        self.score1Lbl.text = "\(self.LeaderData[0].score)"
        self.score2Lbl.text = "\(self.LeaderData[1].score)"
        self.score3Lbl.text = "\(self.LeaderData[2].score)"
        
        //show all 3 views incase hidden in previous cases
        self.user1View.isHidden = false
        self.user2View.isHidden = false
        self.user3View.isHidden = false
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.LeaderData.count
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
        
        if offset < ttlCount  && rowIndex > (LeaderData.count - 3) {
                  getLeaders()
                 do { //delay to load appending data
                     sleep(2)
                 }
             }       
        cell.srLbl.text = "\(LeaderData[rowIndex].userRank)"
        cell.scorLbl.text = "\(LeaderData[rowIndex].score)"
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
        cell.leadrView.layer.masksToBounds = true
        cell.leadrView.layer.cornerRadius = 0 //35
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
        bottomView.backgroundColor = Apps.BASIC_COLOR
        let this = LeaderData.filter{$0.userID == thisUser.userID}
        print(thisUser.userID)
        print(LeaderData)
        
        if !this.isEmpty {
            let rankLabel = UILabel(frame: CGRect(x: 0, y: 10, width: 45, height: 35))
            rankLabel.text = this[0].userRank
            rankLabel.textColor = UIColor.black
            rankLabel.textAlignment = NSTextAlignment.center
            rankLabel.backgroundColor = UIColor.white
            rankLabel.roundCorners(corners: [ .bottomRight, .topRight], radius: 10)
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
                nameLabel = UILabel(frame: CGRect(x: 105, y: 10, width: self.view.frame.width - 200, height: 45))
            }
            nameLabel.text = this[0].name
            nameLabel.textAlignment = .left
            nameLabel.numberOfLines = 0
            nameLabel.lineBreakMode = .byWordWrapping
            nameLabel.textColor = UIColor.white
            bottomView.addSubview(nameLabel)
            
            let scoreLabel = UILabel(frame: CGRect(x: self.view.frame.width - 60, y: 10, width: 60, height: 35))
            scoreLabel.text = this[0].score
            scoreLabel.textColor = UIColor.black
            scoreLabel.textAlignment = .center
            scoreLabel.backgroundColor = UIColor.white
            scoreLabel.roundCorners(corners: [.topLeft, .bottomLeft], radius: 10)
            scoreLabel.layer.masksToBounds = true
            
            bottomView.addSubview(scoreLabel)
            
            self.view.addSubview(bottomView)
        }else{
            //remove subview
            for temp in self.view.subviews {
               // print(temp)
                print(temp.frame)
                if temp.frame.height == 60  { //temp.frame.origin == CGPoint(x: 0, y: 577)-position of bottomView which we want to remove
                    print("origin => \(temp)")
                    temp.removeFromSuperview ()
                }
            }
            print(self.view.subviews)
        }
    }
}
