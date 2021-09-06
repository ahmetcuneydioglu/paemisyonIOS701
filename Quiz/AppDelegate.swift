import UIKit
import CoreData
import GoogleSignIn
import Firebase
import UserNotifications
import FirebaseMessaging
import FBSDKCoreKit
var deviceStoryBoard = "Main"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    let varSys = SystemConfig()
    let gcmMessageIDKey = "test.demo"
    var imgURL = URL(string: "")
    var isImgAttached = false
    var subtitle : String = ""
    var title : String = ""
    var body : String = ""
    var type : String = ""
    var category : [String] = []
    let screenBounds = UIScreen.main.bounds
    
    var loadTime = Date()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //firebase configuration
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //get screen height & width to use it further for diff iphone/ipad screens
        Apps.screenWidth = screenBounds.width
        Apps.screenHeight = screenBounds.height
        
        //to get system configurations parameters as per requirement
       varSys.ConfigureSystem()
       varSys.getUserDetails()
       varSys.LoadLanguages(completion: {})
       varSys.loadCategories()
       varSys.getNotifications()
       varSys.getDeviceInterfaceStyle()
             
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self 
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        //set badge
        if Apps.badgeCount > 0 {
            application.applicationIconBadgeNumber = Apps.badgeCount
        }else{ //clear badge
            application.applicationIconBadgeNumber = 0
        }
        Messaging.messaging().delegate = self
        
        let token = Messaging.messaging().fcmToken ?? "none"
        Apps.FCM_ID = token
        
        //check app is log in or not if not then navigate to login view controller
        if UIDevice.current.userInterfaceIdiom == .pad{
            deviceStoryBoard = "Ipad"
        }else{
            deviceStoryBoard = "Main"
        }
        if UserDefaults.standard.bool(forKey: "isLogedin") {
            
            let initialViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "ViewController")
            let navigationcontroller = UINavigationController(rootViewController: initialViewController)
            navigationcontroller.setNavigationBarHidden(true, animated: false)
            navigationcontroller.isNavigationBarHidden = true
            navigationcontroller.modalPresentationCapturesStatusBarAppearance = true
            
            window?.rootViewController = navigationcontroller
            window?.makeKeyAndVisible()
        }else{
            let initialViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "LoginView")
            let navigationcontroller = UINavigationController(rootViewController: initialViewController) 
            navigationcontroller.setNavigationBarHidden(true, animated: false)
            navigationcontroller.isNavigationBarHidden = true
            navigationcontroller.modalPresentationCapturesStatusBarAppearance = true
            
            window?.rootViewController = navigationcontroller
            window?.makeKeyAndVisible()
        }
        
        return true
    }
    //to redirect back to app from google login in ios 10
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return (GIDSignIn.sharedInstance.handle((url as URL?)!))
    }
    
    //to preview notification in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(Apps.badgeCount)
        completionHandler([.alert,.badge,.sound])
    }
    
    //func called when user tap on notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse,withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo 
        //deduct 1 from badgeCount As user opens notification
        if Apps.badgeCount > 0 {
            Apps.badgeCount -= 1
            UserDefaults.standard.set(Apps.badgeCount, forKey: "badgeCount")
        }
        actionAccordingToData()
        print(" user info - \(userInfo)")
        completionHandler()
    }
    private func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        // The token is not currently available.
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        switch application.applicationState {
            
        case .inactive:
            print("Inactive")
            //Show the view with the content of the push
            completionHandler(.newData)
            
        case .background:
            print("Background")
            //Refresh the local model
            completionHandler(.newData)
            
        case .active:
            print("Active")
            //Show an in-app banner
           // completionHandler(.newData)
        @unknown default:
            print("default case")
        }
        
       // print("USER INFO ",userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    private func application(application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
       // print(fcmToken)
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      //  print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String?] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict as [AnyHashable : Any])
        //send token to application server.
        Apps.FCM_ID = fcmToken!
        varSys.updtFCMToServer()
    }
    
    // Google Sign In
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        //battle modes
        NotificationCenter.default.post(name: Notification.Name("ResetBattle"), object: nil)
        print("called resignActive")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // call function when app is gone to background to quit battle
        NotificationCenter.default.post(name: Notification.Name("QuitBattle"), object: nil)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        //call function when app is live again to check opponent again
        NotificationCenter.default.post(name: Notification.Name("CheckBattle"), object: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
       
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        NotificationCenter.default.post(name: Notification.Name("QuitBattle"), object: nil)
        application.applicationIconBadgeNumber = Apps.badgeCount
    }
   



    func wasLoadTimeLessThanNHoursAgo(thresholdN: Int) -> Bool {
        let now = Date()
        let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(self.loadTime)
        let secondsPerHour = 3600.0
        let intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour
        return intervalInHours < Double(thresholdN)
    }
    
    //func called when user click on notification as received
    func actionAccordingToData(){
        if Apps.nType == "default" {
            //goTo homepage
        }else if Apps.nType == "category" {
            if Apps.nSubCat != "0" {
                let subCatView:subCategoryViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "SubCategoryView") as! subCategoryViewController
                subCatView.catID = Apps.nMainCat //pass main category id to show subcategories regarding to main category there
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = subCatView
                self.window?.makeKeyAndVisible()
            }else if Apps.nMainCat != "0"{
                //open level 1 of category id given
                let levelScreen:LevelView = Apps.storyBoard.instantiateViewController(withIdentifier: "LevelView") as! LevelView
                levelScreen.maxLevel = Apps.nMaxLvl
                levelScreen.catID = Int(Apps.nMainCat) ?? 0
                levelScreen.questionType = "main"
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = levelScreen
                self.window?.makeKeyAndVisible()
            }
        }
    }
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Quiz")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
