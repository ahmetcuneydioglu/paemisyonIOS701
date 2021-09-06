import UIKit
import AVFoundation


struct SubCategory {
    let id:String
    let name:String
    let image:String
    let maxlevel:String
    let status:String
    let noOf:String
}
class subCategoryViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet var subCollectionView: UICollectionView!
    var numberOfItems: Int = 10
    
    
    @IBOutlet weak var titleBarTxt: UILabel!
    
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var catID:String = "48"
    var catName:String = ""
    var subCatData:[SubCategory] = []
    var refreshController = UIRefreshControl()    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForValues(numberOfItems)
        

        
        print("subcategoryview with id and name - \(catID) - \(catName)")
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            let apiURL = "main_id=\(catID)"
            self.getAPIData(apiName: "get_subcategory_by_maincategory", apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        titleBarTxt.text = catName        
    }
    //load sub category data here
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
            subCatData.removeAll()
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    subCatData.append(SubCategory.init(id: "\(val["id"]!)", name: "\(val["subcategory_name"]!)", image: "\(val["image"]!)", maxlevel: "\(val["maxlevel"]!)", status: "\(val["status"]!)", noOf: "\(val["no_of"]!)"))
                }
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.45, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
                self.subCollectionView.reloadData()
                self.numberOfItems = self.subCatData.count
            }
        });
    }
    
    @IBAction func backButton(_ sender: Any) {
        //check if user entered in this view directly from notification ? if Yes then goTo Home page otherwise just go back from notification view
        if self == UIApplication.shared.windows.first!.rootViewController {
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func settingButton(_ sender: Any) {
        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    numberOfItems
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
    let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! subcatCell
     if subCatData.count > 0 {
        gridCell.subCatLabel.text = subCatData[indexPath.row].name
        gridCell.totalQue.text = "\(Apps.STR_QUE) \(subCatData[indexPath.row].noOf)"
        gridCell.logoImg.loadImageUsingCache(withUrl: self.subCatData[indexPath.row].image)
    }else{
        gridCell.subCatLabel.text = "Subcategory"
        gridCell.totalQue.text = "10"
        gridCell.logoImg.image = UIImage(named: "AppIcon")
    }
    gridCell.subCatLabel.textChangeAnimationToRight()
    gridCell.circleImgView.image = UIImage(named: "circle")
    gridCell.circleImgView.tintColor = UIColor.init(named: Apps.tintArr[indexPath.row])
    gridCell.addBottomBorderWithGradientColor(startColor: Apps.arrColors1[indexPath.row] ?? UIColor.blue , endColor: Apps.arrColors2[indexPath.row] ?? UIColor.cyan, width: 2, cornerRadius: 05)
    
    gridCell.setCellShadow()
    
    return gridCell
}
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 10)

        let itemSpacing: CGFloat = 35
        let textAreaHeight: CGFloat = 65

        let width: CGFloat = ((collectionView.bounds.width) - itemSpacing)/2
        let height: CGFloat = width * 10/13 + textAreaHeight
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "LevelView") as! LevelView
        print(subCatData[indexPath.row].maxlevel)
        if self.subCatData[indexPath.row].maxlevel != "0" {
            if self.subCatData[indexPath.row].maxlevel.isInt{
                viewCont.maxLevel = Int(self.subCatData[indexPath.row].maxlevel)!
            }
            viewCont.mainCatid = Int(self.catID)!
            viewCont.catID = Int(self.subCatData[indexPath.row].id)!
            viewCont.questionType = "sub"
            self.navigationController?.pushViewController(viewCont, animated: true)
        }else{
            ShowAlertOnly(title: "", message: Apps.NOT_ENOUGH_QUESTION_TITLE)
        }
    }
}

class subcatCell: UICollectionViewCell {
    
    @IBOutlet var subCatLabel: UILabel!
    @IBOutlet var totalQue: UILabel!
    @IBOutlet var circleImgView: UIImageView!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var gotoButton: UIButton!
}
