import UIKit
import StoreKit

struct CoinStore {
    let id:String
    let productId:String
    let image:String
    let noOfCoins:String
}
class CoinsCell: UICollectionViewCell {
    
    @IBOutlet var noOfCoins: UILabel!
    @IBOutlet weak var coinsImg: UIImageView!
    @IBOutlet weak var getButton: UIButton!
    @IBOutlet weak var bgView: GradientButton!
}

class CoinStoreViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SKPaymentTransactionObserver{
    
    @IBOutlet var coinCollectionView: UICollectionView!
    var numberOfItems: Int = 4
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var CoinData:[CoinStore] = []
    var refreshController = UIRefreshControl()
    
    var isPremium = false
    var transactionInProgress = false
    var productIdentifier = "quiz.earncoins.paemisyon"
    var productIdentifier2 = "com.paemisyon.purchase.coin"
    var products:[SKProduct] = []
    var coinsToAdd = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKPaymentQueue.default().add(self)
       
        if isKeyPresentInUserDefaults(key: "purchase") {
            self.isPremium = UserDefaults.standard.bool(forKey: "purchase")
        }
        fetchProduct()
        
        checkForValues(numberOfItems)
        LoadData()
    }
    //load products here
    func LoadData(){
        CoinData.append(CoinStore.init(id: "1", productId: "quiz.earncoins.paemisyon", image: "coinstore", noOfCoins: "100"))
        CoinData.append(CoinStore.init(id: "2", productId: "quiz.earncoins.paemisyon", image: "coinstore", noOfCoins: "500"))
        CoinData.append(CoinStore.init(id: "3", productId: "com.paemisyon.purchase.coin", image: "coinstore", noOfCoins: "1000"))
        CoinData.append(CoinStore.init(id: "4", productId: "com.paemisyon.purchase.coin", image: "coinstore", noOfCoins: "5000"))
        numberOfItems = CoinData.count
    }
    
    func fetchProduct(){
        self.Loader = self.LoadLoader(loader: self.Loader)
        
        let productIDS = Set([productIdentifier,productIdentifier2])
        
        let request = SKProductsRequest(productIdentifiers: productIDS)
        request.delegate  = self
        request.start()
    }
    
    @IBAction func backButton(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
    }
    
//collectionView
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    numberOfItems
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
    let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CoinsCell
        gridCell.noOfCoins.text = (CoinData.count <= 0) ? "0 \(Apps.STR_COINS)" : "\(CoinData[indexPath.row].noOfCoins) \(Apps.STR_COINS)"
        gridCell.coinsImg.image = UIImage(named: (CoinData[indexPath.row].image))
        gridCell.bgView.startColor = Apps.arrColors1[indexPath.row] ?? UIColor.cyan
        gridCell.bgView.endColor = Apps.arrColors2[indexPath.row] ?? UIColor.blue
        gridCell.getButton.layer.cornerRadius = gridCell.getButton.frame.height / 2
        gridCell.getButton.tag = indexPath.row
        gridCell.getButton.addTarget(self, action: #selector(processPurchase(_:)), for: .touchUpInside)
        gridCell.setCellShadow()
        gridCell.backgroundColor = .clear
    
    return gridCell
}
    
@objc func processPurchase(_ button:UIButton){
    if(!self.isPremium){
        showActions(button.tag)
    }
}
    
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    collectionView.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 10)

    let itemSpacing: CGFloat = 50
    let textAreaHeight: CGFloat = 65

    let width: CGFloat = ((collectionView.bounds.width) - itemSpacing)/2
    let height: CGFloat = width * 10/13 + textAreaHeight
    return CGSize(width: width, height: height)
    }
}

//SKPayment
extension CoinStoreViewController{
    
    func showActions(_ index: Int) {
        if transactionInProgress {
            return
        }
        if SKPaymentQueue.canMakePayments(){
                let payment = SKMutablePayment()
                coinsToAdd = self.CoinData[index].noOfCoins
                print(self.CoinData[index].productId)
                print(coinsToAdd)
                payment.productIdentifier = self.CoinData[index].productId
                SKPaymentQueue.default().add(payment)
                self.transactionInProgress = true
                self.Loader = self.LoadLoader(loader: self.Loader)
              
            }else{
                print("unable to make payment")
            }
    }
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
       for  transaction in  transactions {
            switch transaction.transactionState {
            case .purchasing:
                print("Purchasing")
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                self.transactionInProgress = false
                self.isPremium = true
                
                DispatchQueue.main.async {
                    print("Yayyy !! more coins added !!")
                    self.DismissLoader(loader: self.Loader)
                    self.UpdateStatus(noOfCoins: self.coinsToAdd)
                }
                       
            case .failed:
                print("Transaction Failed",transaction.error!.localizedDescription);
                
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                self.isPremium = false
              
                DispatchQueue.main.async {
                    self.ShowAlert(title: Apps.TRANSACTION_FAILED, message: "\(transaction.error!.localizedDescription)")
                    self.DismissLoader(loader: self.Loader)
                }
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    
    func UpdateStatus(noOfCoins:String){
     
        if(Reachability.isConnectedToNetwork()){
            self.Loader = self.LoadLoader(loader: self.Loader)
         
            let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            let apiURL = "user_id=\(user.userID)&coins=\(noOfCoins)"
            self.getAPIData(apiName: "set_user_coin_score", apiURL: apiURL,completion: {jObj in
               print("JSON",jObj)
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.2, execute: {
                    DispatchQueue.main.async {
                        self.DismissLoader(loader: self.Loader)
                        self.ShowAlertOnly(title: Apps.DONE, message: Apps.COINS_ADDED_MSG)
                    }
                });
            })
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
}

extension CoinStoreViewController:SKProductsRequestDelegate{
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(response.products)
        print(response.description)
        response.invalidProductIdentifiers.forEach { product in
            print("Invalid: \(product)")
        }
        
        response.products.forEach { product in
            self.products.append(product)
            print("Valid: \(product.localizedDescription)")
        }
        
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
            }
        });
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error for request: \(error.localizedDescription)")
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
                self.ShowAlert(title: Apps.ERROR, message: error.localizedDescription)
            }
        });
    }
}
