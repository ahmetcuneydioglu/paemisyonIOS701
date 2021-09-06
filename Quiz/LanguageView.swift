import UIKit

protocol LanguageViewDelegate {
    func ReLaodCategory()
}
class LanguageView:UIViewController, UITableViewDelegate, UITableViewDataSource,LanguageCellDelegate {
     
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var bodyView: UIView!
    @IBOutlet var header: UIView!
    @IBOutlet var footer: UIView!
    
    var langList:[Language] = []
    var selectedElement:Language?
    var Loader: UIAlertController = UIAlertController()
    var delegate:LanguageViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .white
        let config = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        if config.LANGUAGE_MODE == 1{
            if isKeyPresentInUserDefaults(key: DEFAULT_LANGUAGE){
                langList = try! PropertyListDecoder().decode([Language].self, from: (UserDefaults.standard.value(forKey:DEFAULT_LANGUAGE) as? Data)!)
            }else{
                let sys = SystemConfig()
                self.Loader = self.LoadLoader(loader: Loader)
                sys.LoadLanguages(completion: {
                    self.langList = try! PropertyListDecoder().decode([Language].self, from: (UserDefaults.standard.value(forKey:DEFAULT_LANGUAGE) as? Data)!)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.DismissLoader(loader: self.Loader)
                    }
                })
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        addlangToStackView()
        bodyView.center = bodyView.convert(self.view.center, from: bodyView)
    }
    func addlangToStackView(){
        var heightOfTableView: CGFloat = 0.0
        let cells = self.tableView.visibleCells
            for cell in cells {
                heightOfTableView += cell.frame.height
            }
        print("heights - \(heightOfTableView) - \(self.header.frame.height) - \(self.footer.frame.height)")
        let heightVal = heightOfTableView + self.header.frame.height + self.footer.frame.height
        print(heightVal)
        
        //set height anchor for stackView.distribution = .fillProportionally only
        header.heightAnchor.constraint(equalToConstant: self.header.frame.width).isActive = true
        footer.heightAnchor.constraint(equalToConstant: self.footer.frame.height).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: heightOfTableView).isActive = true

        bodyView.frame = CGRect(x: bodyView.frame.origin.x, y: bodyView.frame.origin.y, width: bodyView.frame.width, height: heightVal)
        
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 7
        stackView.layer.cornerRadius = 30
        bodyView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          // Attaching the content's edges to the scroll view's edges
          stackView.leadingAnchor.constraint(equalTo: (bodyView.leadingAnchor)),
          stackView.trailingAnchor.constraint(equalTo: bodyView.trailingAnchor),
          stackView.topAnchor.constraint(equalTo: bodyView.topAnchor),
          stackView.bottomAnchor.constraint(equalTo: bodyView.bottomAnchor),

          // Satisfying size constraints
          stackView.widthAnchor.constraint(equalTo: bodyView.widthAnchor)
        ])
        stackView.distribution = .fillProportionally
        stackView.addArrangedSubview(header)
        stackView.addArrangedSubview(tableView)
        stackView.addArrangedSubview(footer)
    }
    
    @IBAction func OKButton(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
         delegate?.ReLaodCategory()
    }
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(langList.count)
        return langList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LanguageCell =
            tableView.dequeueReusableCell(withIdentifier: "LanguageCell") as! LanguageCell
        cell.itemLabel.text = langList[indexPath.row].name
        cell.itemLabel.tag = langList[indexPath.row].id
       
        cell.path = indexPath //pass to language cell file
        
        if langList[indexPath.row].id == selectedElement?.id || langList[indexPath.row].id == UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG) {
            cell.radioButton.isSelected = true
        } else {
            cell.radioButton.isSelected = false
        }
        cell.initCellItem()
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    //set default_user_lang to use throuhout the app
    func didToggleRadioButton(_ indexPath: IndexPath) {
        selectedElement = langList[indexPath.row]
        UserDefaults.standard.set(selectedElement?.id, forKey: DEFAULT_USER_LANG)
    }
    func deselectOtherButton(_ currCell: UITableViewCell){
            let tappedCellIndexPath = tableView.indexPath(for: currCell)!
               let indexPaths = tableView.indexPathsForVisibleRows
               for indexPath in indexPaths! {
                   if indexPath.row != tappedCellIndexPath.row && indexPath.section == tappedCellIndexPath.section {
                       let cell = tableView.cellForRow(at: IndexPath(row: indexPath.row, section: indexPath.section)) as! LanguageCell
                            let deselectedImage = UIImage(named: "unselected")
                            cell.radioButton.isSelected = false
                            cell.radioButton.setImage(deselectedImage, for: .normal)
                   }
              }
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        let cell:LanguageCell = self.tableView.cellForRow(at: indexPath) as! LanguageCell
        cell.radioButtonTapped(cell.radioButton)
    }
}
