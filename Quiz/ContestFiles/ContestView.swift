import UIKit
import EVTopTabBar

class ContestView: UIViewController, EVTabBar {
        
    @IBOutlet weak var coins: UIButton!
    
    var Loader: UIAlertController = UIAlertController()
            
    var dUser:User? = nil
    
    var pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var topTabBar: EVPageViewTopTabBar? {
        didSet {
            topTabBar?.fontColors = (selectedColor: UIColor.black, unselectedColor: UIColor.gray)
            topTabBar?.leftButtonText = "PAST"
            topTabBar?.middleButtonText  = "LIVE"
            topTabBar?.rightButtonText = "UPCOMING"
            topTabBar?.labelFont = UIFont(name: "Helvetica", size: 14)!
            topTabBar?.indicatorViewColor = Apps.BASIC_COLOR//UIColor.blue
            topTabBar?.backgroundColor = UIColor.white
            topTabBar?.delegate = self
        }
    }
    var subviewControllers: [UIViewController] = []
    var shadowView = UIImageView(image: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.coins.setTitle(Apps.COINS, for: .normal)
        
        topTabBar = EVPageViewTopTabBar(for: .three, withIndicatorStyle: .buttonWidth )
        
        let PAST = self.storyboard!.instantiateViewController(withIdentifier: "ContestMainView") as! ContestMainView
          PAST.tabSelect = "past_contest"
        let LIVE = self.storyboard!.instantiateViewController(withIdentifier: "ContestMainView") as! ContestMainView
            LIVE.tabSelect = "live_contest"
        let UPCOMING = self.storyboard!.instantiateViewController(withIdentifier: "ContestMainView") as! ContestMainView
           UPCOMING.tabSelect = "upcoming_contest"
        subviewControllers = [PAST, LIVE, UPCOMING]
        
        setupPageView()
        setupConstraints()
        
    }
                
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


//MARK: EVTabBarDataSource
extension ContestView: EVTabBarDelegate {
    func willSelectViewControllerAtIndex(_ index: Int, direction: UIPageViewController.NavigationDirection) {
        
        if index > subviewControllers.count {
            pageController.setViewControllers([subviewControllers[subviewControllers.count - 1]], direction: direction, animated: true, completion: nil)
        } else {
            pageController.setViewControllers([subviewControllers[index]], direction: direction, animated: true, completion: nil)
        }
    }
    
    func setupConstraints() {
        let views: [String:AnyObject] = ["menuBar" : topTabBar!, "pageView" : pageController.view, "shadow" : shadowView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[menuBar]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-85-[menuBar(==50)][pageView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[pageView]|", options: [], metrics: nil, views: views))
        
        pageController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[shadow]|", options: [], metrics: nil, views: views))
        pageController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[shadow(0)]", options: [], metrics: nil, views: ["shadow" : shadowView]))
    }
}
