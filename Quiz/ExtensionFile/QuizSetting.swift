import Foundation
import UIKit
import AVFoundation

//apps setting and default value will be store here and used everywhere
struct Apps{
    static var URL = "http://paemisyon.com/paem701/api-v2.php"
    static var ACCESS_KEY = "6808"
    
    static let JWT = "Ahmet263272"
    
    //----------------------set values----------------------
    static let QUIZ_PLAY_TIME:CGFloat = 25 // set timer value for play quiz
    static let GROUP_BTL_WAIT_TIME:Int = 180 // set timer value for players to join group battle
       
    static let OPT_FT_COIN = 4 // how many coins will be deduct when we use 50-50 lifeline?
    static let OPT_SK_COIN = 4 // how many coins will be deduct when we use SKIP lifeline?
    static let OPT_AU_COIN = 4 // how many coins will be deduct when we use AUDIENCE POLL lifeline?
    static let OPT_RES_COIN = 4 // how many coins will be deduct when we use RESET TIMER lifeline?
    
    static let QUIZ_R_Q_POINTS = 4 // how many points will user get when he select right answer in play area
    static let QUIZ_W_Q_POINTS = 2 // how many points will deduct when user select wrong answer in play area
    static let CONTEST_RIGHT_POINTS = 3 // how many points will user get when he select right answer in Contest
    
    static var REWARD_COIN = "4" //used to add coins to user coins when user watch reward video ad
    
    //static let BANNER_AD_UNIT_ID = "ca-app-pub-3940256099942544/2934735716"
    //static let REWARD_AD_UNIT_ID = "ca-app-pub-3940256099942544/1712485313"
    //static let INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-3940256099942544/4411468910"
    static let APP_OPEN_UNIT_ID = "ca-app-pub-3940256099942544/5662855259"
    //static let AD_TEST_DEVICE = ["e61b6b6ac743a9c528bcda64b4ee77a7","8099b28d92fa3eae7101498204255467"]
    
    static let RIGHT_ANS_COLOR = UIColor.rgb(35, 176, 75, 0.6) //right answer color
    static let WRONG_ANS_COLOR = UIColor.rgb(237, 42, 42, 0.6) //wrong answer color
   
    static let BASIC_COLOR = UIColor.rgb(29, 108, 186, 1.0)
    static let BASIC_COLOR_CGCOLOR = UIColor.rgb(29, 108, 186, 1.0).cgColor
    
    //----------------------other colors----------------------
    static let defaultOuterColor = Apps.BASIC_COLOR
    static let defaultInnerColor = UIColor.rgb(84,193,255,1)
    static let defaultPulseFillColor = UIColor.clear
    
    static let GRAY_CGCOLOR = UIColor.rgb(198, 198, 198, 1.0).cgColor
    static let BG1_CGCOLOR = UIColor.rgb(243, 243, 247, 1.0).cgColor
    static let WHITE_ALPHA = UIColor.rgb(255, 255, 255, 0.4)
    
    static let LEVEL_TEXTCOLOR = UIColor.rgb(168, 168, 168, 1)
    
    //----------------------gradient Colors----------------------
    let purple1 = UIColor.rgb(158, 89, 225, 1)
    let purple2 = UIColor.rgb(241, 125, 196, 1.0)
    
    let sky1 = UIColor.rgb(67,155,210,1.0)
    let sky2 = UIColor.rgb(115,225,192,1.0)
    
    let orange1 = UIColor.rgb(227,119,67,1.0)
    let orange2 = UIColor.rgb(237,159,63,1.0)
    
    static let blue1 = UIColor.rgb(29,108,186,1.0)
    static let blue2 = UIColor.rgb(84,193,255,1.0)
    
    let pink1 = UIColor.rgb(195,15,142,1.0)
    let pink2 = UIColor.rgb(251,82,147,1.0)
    
    let green1 = UIColor.rgb(60,131,70,1.0)
    let green2 = UIColor.rgb(139,209,136,1.0)
    
    static var arrColors1 = [UIColor(named: "purple1"),UIColor(named: "sky1"),UIColor(named: "blue1"),UIColor(named: "orange1"),UIColor(named: "pink1"),UIColor(named: "green1")]
    static var arrColors2 = [UIColor(named: "purple2"),UIColor(named: "sky2"),UIColor(named: "blue2"),UIColor(named: "orange2"),UIColor(named: "pink2"),UIColor(named: "green2")]

    static var tintArr = ["purple2", "sky2","blue2","orange2","pink2","green2"] //NOTE: arrColors1 & arrColors2 & tintArr - arrays should have same values/count
    
    static var APPEARANCE = "light"
    
    //----------------------App Information - set from admin panel----------------------
    static var SHARE_APP = "https://itunes.apple.com/in/app/Quiz online App/1467888574?mt=8"
    static var MORE_APP = "itms-apps://itunes.com/apps/89C47N4UTZ"
    static var SHARE_APP_TXT = "Hello"
    static var TOTAL_PLAY_QS = 10 // how many there will be total question in quiz play
    static var TOTAL_BATTLE_QS = 10 // no_of_que for Group Battle
    
    static var ANS_MODE = "0"
    static var FORCE_UPDT_MODE = "1"
    static var CONTEST_MODE = "1"
    static var DAILY_QUIZ_MODE = "1"
    static var FIX_QUE_LVL = "0"
    static var RANDOM_BATTLE_WITH_CATEGORY = "1"
    static var GROUP_BATTLE_WITH_CATEGORY = "1"
    static var IN_APP_PURCHASE = "0"
    
    //----------------------variables to store push notification response parameters----------------------
    static var nTitle = ""
    static var nMsg = ""
    static var nImg = ""
    static var nMaxLvl = 0
    static var nMainCat = ""
    static var nSubCat = ""
    static var nType = ""
    static var badgeCount = UserDefaults.standard.integer(forKey: "badgeCount")
    
    //----------------------APis - static values----------------------
    static let USERS_DATA = "get_user_by_id"
    static var REFER_CODE = "refer_code"
    static let FRIENDS_CODE = "friends_code"
    static let SYSTEM_CONFIG = "get_system_configurations"
    static let NOTIFICATIONS = "get_notifications"
    static let API_BOOKMARK_GET = "get_bookmark"
    static let API_BOOKMARK_SET = "set_bookmark"
    
    static var opt_E = false
    static var ALL_TIME_RANK:Any = "0"
    static var COINS = "0"
    static var SCORE: Any = "0"
    static var REFER_COIN = "0"// added to friend's coins
    static var EARN_COIN = "0" //added to user's own coins
    
    static var storyBoard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
    
    static var screenHeight = CGFloat(0)
    static var screenWidth = CGFloat(0)
    
    static var FCM_ID = " "
    //----------------------Home ViewController Strings----------------------
    static let QUIZ_ZONE = "Kategoriler"
    static let PLAY_ZONE = "Çalışma Alanı"
    static let BATTLE_ZONE = "Yarışma"
    static let CONTEST_ZONE = "Deneme Sınavları"
    static let IMG_QUIZ_ZONE = "quizzone"
    static let IMG_PLAYQUIZ = "playquiz"
    static let IMG_BATTLE_QUIZ = "battlequiz"
    static let IMG_CONTEST_QUIZ = "contestquiz"
    
    static let DAILY_QUIZ_PLAY = "Günlük Quiz"
    static let RNDM_QUIZ = "Karışık Quiz"
    static let TRUE_FALSE = "Doğru / Yanlış"
    static let SELF_CHLNG = "Test Oluştur"
    static let PRACTICE = "Hızlı Tekrar"
    static let GROUP_BTL = "Grup Yarışması"
    static let RNDM_BTL = "Rasgele Yarışma"
    
    static let CONTEST_PLAY_TEXT = "Denemeler"
    static let JOIN_NOW = "Şimdi Katıl"
    
    //----------------------colors----------------------
    static let SKY1 = "sky1"
    static let ORANGE1 = "orange1"
    static let PURPLE1 = "purple1"
    static let GREEN1 = "green1"
    static let BLUE1 = "blue1"
    static let PINK1 = "pink1"
    
    static let SKY2 = "sky2"
    static let ORANGE2 = "orange2"
    static let PURPLE2 = "purple2"
    static let GREEN2 = "green2"
    static let BLUE2 = "blue2"
    static let PINK2 = "pink2"
    
    static let GRP_BTL = "groupbattle"
    static let RNDM = "random"
    static let CONTEST_IMG = "contest"
    
    //----------------------strings to Translate----------------------
    static let APP_NAME = "Paemisyon (v7.0.1)"
    static var SHARE_MSG = "Paemisyon uygulamasını kullanarak coin kazandım. Ayrıca aşağıdaki linkten uygulamayı indirerek coin kazanabilir ve giriş yaparken referans kodunu girebilirsiniz. - "
    static let NO_NOTIFICATION = "Bildirimler kullanılamıyor"
    static let COMPLETE_LEVEL = "Tebrikler !! \n ZAFERR"
    static let NOT_COMPLETE_LEVEL = "Bir dahaki sefere daha iyi şanslar \n DEFEAT"
    static let PLAY_AGAIN = "Tekrar Dene"
    static let NOT_ENOUGH_QUESTION_TITLE = "Yetersiz Soru"
    static let NO_ENOUGH_QUESTION_MSG = "Bu seviyede test başlatmak için yeterli soru yok"
    static let COMPLETE_ALL_QUESTION = "Tüm Soruları Tamamladınız !!"
    static let LEVET_NOT_AVAILABEL = "Level mevcut değil"
    static let STATISTICS_NOT_AVAIL = "Veri Mevcut Değil"
    static let SKIP = "GEÇ"
    static let MSG_ENOUGH_COIN = "Yeterli coin yok !"
    static let NEED_COIN_MSG1 = "Yeterli coininiz yok."
    static let NEED_COIN_MSG2 = "coins to use this lifeline."
    static let NEED_COIN_MSG3 = "Kısa video izle & coin kazan."
    static let WATCH_VIDEO = "ŞİMDİ İZLE"
    static let EXIT_APP_MSG = "Çıkmak istediğine emin misin?"
    static let EXIT_PLAY = "Testten çıkmak istiyor musunuz?"
    static let NO_INTERNET_TITLE = "Internet yok!"
    static let NO_INTERNET_MSG = "İnternet bağlantını kontrol et!"
    static let LEVEL_LOCK = "Bu level sizin için kilitli"
    static let LOGOUT_TITLE = "ÇIKIŞ"
    static let LOGOUT_MSG = "Emin misin!! \n Çıkmak istiyor musun?"
    static let LIFELINE_ALREDY_USED_TITLE = "Life Line"
    static let LIFELINE_ALREDY_USED = "Zaten kullanıldı"
    static let YES = "EVET"
    static let NO = "HAYIR"
    static let DONE = "Tamam"
    static let OOPS = "Oops!"
    static let ROBOT = "Robot"
    static let BACK = "GERİ"
    static let SHOW_ANSWER = "Cevabı Göster"
    static let LEVEL = "Level :"
    static let TRUE_ANS = "Doğru Cevap:"
    static let MATCH_DRAW = "Eşitlik!"
    static let REPORT_QUESTION = "Soruyu Bildir"
    static let TYPE_MSG = "Mesaj yaz"
    static let SUBMIT = "Gönder"
    static let CANCEL = "Kapat"
    static let FROM_LIBRARY = "Galeri"
    static let TAKE_PHOTO = "Camera"
    static let NO_BOOKMARK = "Sorular mevcut değil"
    static let LEAVE_MSG = "Emin misin , Çıkmak istiyor musun ?"
    static let ERROR = "Error"
    static let ERROR_MSG = "Veriler alınırken hata oluştu"
    static let MSG_NM = "Lütfen Adını gir"
    static let MSG_ERR = "Kullanıcı Oluşturma Hatası"
    static let PROFILE_UPDT = "Profil Güncelle"
    static let WARNING = "Uyarı"
    static let WAIT = "Lütfen bekle...⏳"
    static let DISMISS = "Reddet"
    static let OK = "OK"
    static let OKAY = "OKAY"
    static let HELLO = "Selam,"
    static let USER = "User"
    static let INVALID_QUE = "Geçersiz Soru"
    static let INVALID_QUE_MSG = " Bu Soru yanlış değere sahip."
    static let ENTER_MAILID = "Lütfen e-posta girin."
    //----------------------REVIEW----------------------
    static let EXTRA_NOTE = "Soru Notu"
    static let UN_ATTEMPTED = "İşaretlenmeyen"
    //----------------------RESET PASSWORD----------------------
    static let RESET_FAILED = "Sıfırlama Başarısız"
    static let RESET_TITLE = "Parolayı Sıfırlamak için E-posta başarıyla gönderildi"
    static let RESET_MSG = "Mail adresini kontrol et"
    //----------------------ALERT MSG----------------------
    static let NO_DATA_TITLE = "Veri yok"
    static let NO_DATA = "Veri bulunamadı !!!"
    //----------------------LOGIN ALERTS----------------------
    static let APPLE_LOGIN_TITLE =  "Desteklenmiyor"
    static let APPLE_LOGIN_MSG = "Apple oturum açma cihazınızda desteklenmiyor. başka bir giriş yöntemi deneyin"
     static let VERIFY_MSG = "Lütfen Önce E-postayı Doğrulayın ve Devam Edin !"
     static let VERIFY_MSG1 = "Kullanıcı doğrulama e-postası gönderildi"
     static let CORRECT_DATA_MSG = "Lütfen doğru kullanıcı adı ve şifreyi giriniz"
    //----------------------REFER CODE----------------------
    static let REFER_CODE_COPY = "Panoya Kopyalanan Kodu Göster"
    static let REFER_MSG1 = "Bir Arkadaşa Tavsiye Edin, alacaksınız"
    static let REFER_MSG2 = "referans kodunuz her kullanıldığında kazanacağınız koun."
    static let REFER_MSG3 = "creferans kodunuzu kullanarak COİN "
    //----------------------SELF CHALLENGE----------------------
    static let ALERT_TITLE = "Soru Sayısını Seçin"
    static let ALERT_TITLE1 = "Test Oynatma süresini seçin"
    static let BACK_MSG = "Bu testi henüz göndermediniz."
    static let SUBMIT_TEST = "Bu testi göndermek istiyor musunuz?"
    static let RESULT_TXT = "meydan okumayı tamamladınız \n in"
    static let SECONDS = "Sec"
    static let CHLNG_TIME = "meydan okuma zamanı:"
    //----------------------FONT----------------------
    static let FONT_TITLE =  "Font Size"
    static let FONT_MSG = "Büyüt/Küçült Font boyutu\n\n\n\n\n\n"
    //----------------------IMAGE----------------------
    static let IMG_TITLE =  "İmage Seç"
    static let NO_CAMERA = "Kameranız yok"
    //----------------------BATTLE----------------------
    static let GAME_OVER = "Oyun bitti! Tekrar oyna "
    static let WIN_BATTLE = "Savaşı sen kazandın"
    static let CONGRATS = "Tebrikler!!"
    static let OPP_WIN_BATTLE = "Savaşı kazan"
    static let LOSE_BATTLE = "Bir sonraki sefere bol şans"
    //----------------------SHARE TEXT-SELF CHALLENGE----------------------
    static let SELF_CHALLENGE_SHARE1 = "bitirdim"
    static let SELF_CHALLENGE_SHARE2 = "Test oluştur da dakika"
    static let SELF_CHALLENGE_SHARE3 = "Quizde dakika"
    //----------------------SHARE QUIZ PLAY RESULT----------------------
    static let SHARE1 = "Leveli tamamladım"
    static let SHARE2 = "bu skor ile"
    //----------------------apps update info string----------------------
    static let UPDATE_TITLE = "Yeni güncelleme mevcut!!"
    static let UPDATE_MSG = "Uygulama için Yeni Güncelleme mevcut, daha fazla işlevsellik ve iyi bir deneyim elde etmek için lütfen Uygulamayı Güncelleyin"
    static let UPDATE_BUTTON = "Şimdi Güncelle"
    static let DAILY_QUIZ = "Günlük Quiz"
    static let DAILY_QUIZ_TITLE = "Tekrar Oyna"
    static let DAILY_QUIZ_MSG_SUCCESS = "Günlük Quiz Tamamlandı"
    static let DAILY_QUIZ_MSG_FAIL = "Günlük Quiz Başarısız"
    static let DAILY_QUIZ_SHARE_MSG = "Günlük quizi bu puanla tamamladım "
    static let RANDOM_QUIZ_MSG_SUCCESS = "Karışık Quiz Tamamlandı"
    static let RANDOM_QUIZ_MSG_FAIL = "Karışık Quiz Başarısız"
    static let RANDOM_QUIZ_SHARE_MSG = "Karışık quizi bu puanla tamamladım "
    static let TF_QUIZ_MSG_SUCCESS = "DOĞRU/YANLIŞ Quiz Tamamlandı"
    static let TF_QUIZ_MSG_FAIL = "DOĞRU/YANLIŞ Quiz Başarısız"
    static let TF_QUIZ_SHARE_MSG = "DOĞRU/YANLI Quizi bu skor ile tamamladım "
    
    static let PLAYED_ALREADY = "Zaten Çözdün"
    static let PLAYED_MSG = "Günlük Quiz'i bugün zaten çözdünüz. Lütfen yarın tekrar gelin !"
    
    static let NO_QSTN = "Bugün quiz yok"
    static let NO_QSTN_MSG = "Bugün Günlük Test Yok. Lütfen Yarın Tekrar Deneyin !"
    
    static let STR_QUE = "Soru"
    static let STR_CATEGORY = "Kategori"
    static let STR_ANSWER = "Cevap:"
    //----------------------leaderboard Filters / options----------------------
    static let ALL = "Tüm"
    static let MONTHLY = "Aylık"
    static let DAILY = "Günlük"
    //----------------------CONTEST----------------------
    static let SHARE_CONTEST = "Deneme Sınavını bu skorla tamamladım"
    static let MSG_CODE = "Lütfen Kod Gir"
    static let NO_COINS_TTL = "Yeterli koinin yok"
    static let NO_COINS_MSG = "Koin kazan ve denemeye gir"
    static let PLAY_BTN_TITLE = "Başla"
    static let LB_BTN_TITLE = "Lider Tahtası"
    static let STR_COINS = "coins"
    static let STR_ENDS_ON = "Biter"
    static let STR_ENDING_ON = "Bitiyor"
    static let STR_STARTS_ON = "Başlıyor "
     //----------------------MOBILE LOGIN----------------------
    static let MSG_CC = "Lütfen ülke kodunu doğru formatta gir"
    static let MSG_NUM = "Lütfen telefon numaranı doğru formatta gir"
    //----------------------USER STATUS----------------------
    static let DEACTIVATED = "Hesap Devre Dışı Bırakıldı"
    static let DEACTIVATED_MSG = "Hesabınız Yönetici tarafından Devre Dışı Bırakıldı"
    //----------------------BATTLE MODES----------------------
    static let ROOM_NAME = "OnlineUser"
    static let PRIVATE_ROOM_NAME = "PrivateRoom"
    static let PUBLIC_ROOM_NAME = "PublicRoom"
    
    static let GAMEROOM_DESTROY_MSG = "Emin misin? Oyun'u yok etmek istiyormusun?"
    static let GAMEROOM_EXIT_MSG = "Oyundan çıkmak istediğinizden emin misiniz?"
    static let USER_NOT_JOIN = "Kullanıcı henüz katılmadı, başlamak için en az bir kullanıcının katılması gerekiyor"
    static let MAX_USER_REACHED = "Maksimum Kullanıcıya Ulaşıldı"
    static let NO_PLYR_LEFT = "Odada Oyuncu Kalmadı"
    
    static let SELECT_CATGORY = "Kategori Seç"
    static let NO_OFF_QSN = "Soru sayısı"
    static let TIMER = "Time"
    
    static let QSTN = "Sorular"
    static let MINUTES = "Dakika"
    static let PLYR = "Oyuncu"
    static let BULLET = "●"
    
    static let BUSY = "busy"
    static let INVITE = "Invite"
    
    static let GAMECODE_INVALID = "Geçersiz oyun kodu"
    static let GAME_CLOSED = "Yarışma Devre Dışı Bırakıldı veya Yarışma Zaten Başladı"
    static let GAMEROOM_ENTERCODE = "Yarışma kodunu gir"
    static let MSG_GAMEROOM_SHARE = "Yarışma Grup kodum: "
    
    static let GAMEROOM_CLOSE_MSG = "Yarışma devre dışı bırakıldı"
    static let GAMEROOM_WAIT_ALERT = "En az bir kullanıcının oyuna katılmasını bekleyin"
    static let STAY_BACK = "GERİDE KAL"
    static let LEAVE = "AYRIL"
    
    static let NO_USER_JOINED = "Hiç kimse katılmadı"
    static let NO_USER_JOINED_MSG = "Görünüşe göre henüz hiçbir kullanıcı oyuna katılmadı."
    static let EXIT = "ÇIKIŞ"
    
    static let BTL_WAIT_MSG = "Lütfen bekle! Süre dolduktan sonra sonuçları göreceksiniz."
    
    //----------------------Placeholder Text - Login / Sign Up / GameRoomCode----------------------
    static let P_EMAIL = " Email"
    static let P_PASSWORD = " Password"
    static let P_PHONENUMBER = "Tel. numarası"
    static let P_REFERCODE = " Ref kodu (Boş kalabilir)"
    static let P_NAME = " Ad"
    static let P_GAMECODE = " Oyun kodu"
    static let P_EMAILTXT = " Email adresi gir"
    static let P_OTP = " OTP(Tek kullanımlık şifre) gir"
    
    //----------------------IAP Strings----------------------
    static let COINS_ADDED_MSG = "Coin'ler Başarıyla Eklendi"
    static let PURCHASE = "Satın al"
    static let RESTORE = "Restore"
    
    static let PURCHASE_COINS = "Coin Satın Al"
    
    static let TRANSACTION_FAILED = "İşlem Başarısız!"
    static let VALIDATION_FAILED = "Doğrulama başarısız"
    static let VALIDATION_FAILED_MSG = "Uygulama İçi Satın Alma doğrulaması Başarısız"
    
    static let LANG = "en-US"
}
