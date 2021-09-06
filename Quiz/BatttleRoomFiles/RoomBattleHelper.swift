import Foundation
import CallKit
import UIKit
import FirebaseDatabase

extension RoomBattlePlayView:UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.joinedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BattleUserScoreCell", for: indexPath) as! BattleUserScoreCell
        
        let index = indexPath.row
        let currUser = self.joinedUsers[index]
        cell.userName.text = currUser.userName
        print(cell.userName.text ?? "user")
        if currUser.userImage != ""{
            DispatchQueue.main.async {
                cell.userImg.loadImageUsingCache(withUrl: currUser.userImage)
            }
        }else{
            cell.userImg.image = UIImage(systemName: "person.fill")
        }
        cell.userRight.text = currUser.rightAns
        cell.userWrong.text = currUser.wrongAns
        
        //user leave
        if currUser.isLeave ?? false{
            cell.mainView.backgroundColor = .lightGray
        }else{
            cell.mainView.backgroundColor = .white
        }
        
        return cell
    }
    
    func CheckPlayerAttemp(){
        if self.isCompleted{
            return
        }
        
        var isAllAttempt = false
        for val in self.joinedUsers{
            if val.isJoined && !val.isLeave!{
                if (Int(val.rightAns)! + Int(val.wrongAns)!) == self.quesData.count{
                    isAllAttempt = true
                }else{
                    isAllAttempt = false
                    break
                }
            }
        }
        
        if isAllAttempt{
            self.CompleteBattle()
            self.isCompleted = true
        }
    }
}
