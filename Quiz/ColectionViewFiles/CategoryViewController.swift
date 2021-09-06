import UIKit
import AVFoundation
import QuartzCore

//structure for category
struct Category: Codable {
    let id:String
    let name:String
    let image:String
    let maxlvl:String
    let noOf:String
    let noOfQues:String
}
class CategoryViewController: UIViewController{
    
    @IBOutlet var collectionView: ASCollectionView!
    @IBOutlet weak var sBtn: UIButton!
    
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var isCategoryBattle = false
    var isGroupCategoryBattle = false
    
    var catData:[Category] = [] 
    var langList:[Language] = []
    var refreshController = UIRefreshControl()
    var config:SystemConfiguration?
    var apiName = "get_categories"
    var apiExPeraforLang = ""
    var numberOfItems: Int = 7 //10
    let collectionElementKindHeader = "Header"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
                
        if isKeyPresentInUserDefaults(key: DEFAULT_SYS_CONFIG){
             config = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        }
        checkForValues(numberOfItems)
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            if config?.LANGUAGE_MODE == 1{
                apiName = "get_categories_by_language"
                apiExPeraforLang = "&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))"
            }
            let apiURL = "" + apiExPeraforLang
            self.getAPIData(apiName: apiName, apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        refreshController.addTarget(self,action: #selector(self.RefreshDataOnPullDown),for: .valueChanged)
        collectionView.refreshControl = refreshController
        
        collectionView.delegate = self
        collectionView.asDataSource = self
    }
    func ReLaodCategory() {
        apiExPeraforLang = "&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))"
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            let apiURL = "" + apiExPeraforLang
            self.getAPIData(apiName: apiName, apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    // refresh function
    @objc func RefreshDataOnPullDown(){
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            let apiURL = "" + apiExPeraforLang
            self.getAPIData(apiName: apiName, apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    
    //load category data here
    func LoadData(jsonObj:NSDictionary){
        print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                })
            }
            
        }else{
            //get data for category
            catData.removeAll()
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    catData.append(Category.init(id: "\(val["id"]!)", name: "\(val["category_name"]!)", image: "\(val["image"]!)", maxlvl: "\(val["maxlevel"]!)", noOf: "\(val["no_of"]!)", noOfQues: "\(val["no_of_que"]!)"))
                }
            }
            
            //Add collectionView dimesnsions from ASACollection
            DispatchQueue.main.async {
                self.collectionView.register(UINib(nibName: self.collectionElementKindHeader, bundle: nil), forSupplementaryViewOfKind:  self.collectionElementKindHeader, withReuseIdentifier: "header")
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
           DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
                self.numberOfItems = self.catData.count
                self.checkForValues(self.numberOfItems)
                self.collectionView.reloadData()
                //self.catetableView.reloadData()
                self.refreshController.endRefreshing()
            }
        });
    }

    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func settingButton(_ sender: Any) {
        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
}

extension CategoryViewController: ASCollectionViewDelegate {

    func loadMoreInASCollectionView(_ asCollectionView: ASCollectionView) {
        if numberOfItems > 30 {
            collectionView.enableLoadMore = false
            return
        }
        collectionView.loadingMore = false
        collectionView.reloadData()
    }
}

extension CategoryViewController: ASCollectionViewDataSource {

    func numberOfItemsInASCollectionView(_ asCollectionView: ASCollectionView) -> Int {
        print("total count- \(numberOfItems)")
        return numberOfItems
    }

    func collectionView(_ asCollectionView: ASCollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GridCell
        if catData.count > 0{
            gridCell.catLabel.text = catData[indexPath.row].name
            gridCell.totalQue.text = "\(Apps.STR_QUE): \(catData[indexPath.row].noOfQues)"
            gridCell.logoImg.loadImageUsingCache(withUrl: self.catData[indexPath.row].image)
        }else{
            gridCell.catLabel.text = "Category"
            gridCell.totalQue.text = "Que: 0"
            gridCell.logoImg.image = UIImage(named: "AppIcon")
        }
        gridCell.catLabel.textChangeAnimationToRight()
        gridCell.circleImgView.image = UIImage(named: "circle")
        gridCell.circleImgView.tintColor = UIColor.init(named: Apps.tintArr[indexPath.row])
        gridCell.bottomLineView.startColor = Apps.arrColors1[indexPath.row] ?? UIColor.blue
        gridCell.bottomLineView.endColor = Apps.arrColors2[indexPath.row] ?? UIColor.cyan
        gridCell.setCellShadow()
        
        return gridCell
    }

    func collectionView(_ asCollectionView: ASCollectionView, headerAtIndexPath indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: ASCollectionViewElement.Header, withReuseIdentifier: "header", for: indexPath)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isCategoryBattle == true{
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "BattleViewController") as! BattleViewController
            viewCont.isCategoryBattle = true
            viewCont.catID = Int(self.catData[indexPath.row].id)!
            self.navigationController?.pushViewController(viewCont, animated: true)
        }else if isGroupCategoryBattle == true {
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "GroupBattleView") as! GroupBattleView
            viewCont.catID = Int(self.catData[indexPath.row].id)! 
            self.navigationController?.pushViewController(viewCont, animated: true)
        }else{
            if catData.count > 0 {
                if(catData[indexPath.row].noOf == "0"){
                    // this category dose not have any sub category so move to level screen
                    let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "LevelView") as! LevelView
                    if catData[indexPath.row].maxlvl != "0" { //if there's no levels or no questions then do nothing
                        if catData[indexPath.row].maxlvl.isInt{
                            viewCont.maxLevel = Int(catData[indexPath.row].maxlvl)!
                        }
                        viewCont.catID = Int(self.catData[indexPath.row].id)!
                        viewCont.questionType = "main"
                        self.navigationController?.pushViewController(viewCont, animated: true)
                    }else{
                        ShowAlertOnly(title: "", message: Apps.NOT_ENOUGH_QUESTION_TITLE)
                    }
                }else{
                let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "subcategoryview") as! subCategoryViewController
                viewCont.catID = catData[indexPath.row].id
                viewCont.catName = catData[indexPath.row].name
                print("cat id and name -- \(catData[indexPath.row].id) \(catData[indexPath.row].name)")
                self.navigationController?.pushViewController(viewCont, animated: true)
                }
            }
        }
    }
}

class GridCell: UICollectionViewCell {

    @IBOutlet var catLabel: UILabel!
    @IBOutlet var totalQue: UILabel!
    @IBOutlet var circleImgView: UIImageView!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var bottomLineView: GradientButton!
    @IBOutlet weak var gotoButton: UIButton!
}
