import UIKit

protocol LanguageCellDelegate {
    func didToggleRadioButton(_ indexPath: IndexPath)
    func deselectOtherButton(_ currCell: UITableViewCell)
}

class LanguageCell: UITableViewCell {

    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var radioButton: UIButton!
    var delegate: LanguageCellDelegate?

    public var path: IndexPath!
     
    
    func initCellItem() {

        if self.radioButton.isSelected{
                let selectedImage = UIImage(named: "selected")
                self.radioButton.setImage(selectedImage, for: .normal)
        }else{
                let deselectedImage = UIImage(named: "unselected")
                radioButton.setImage(deselectedImage, for: .normal)
        }
      
        radioButton.addTarget(self, action: #selector(self.radioButtonTapped), for: .touchUpInside)
    }
    
    @objc func radioButtonTapped(_ radioButton: UIButton) {
        print("radio button tapped")
        let isSelected = !self.radioButton.isSelected
        self.radioButton.isSelected = isSelected
        if isSelected {
            delegate?.deselectOtherButton(self)
            let selectedImage = UIImage(named: "selected")
            radioButton.setImage(selectedImage, for: .normal)
        }
        let i_path = path!
        delegate?.didToggleRadioButton(i_path)
    }
}
