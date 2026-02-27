//
//  MessageOverViewViewController.swift
//  ShinGikenApp
//
//  Created by 山﨑貴史 on 2026/01/26.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class MessageOverViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    let ipStr = ShareData.shared.IP
    var messageUserName: [String] = []
    
    var resUserInfo: JSON = JSON()
    
    var moveMessageID: String = ""
    
    let cullentReadDict: [String: Int] = UserDefaults.standard.dictionary(forKey: "currentReadDict") as? [String: Int] ?? [:]
    
    let userDataJSON = [["userID": 1, "otherID":3, "readedID":5], ["userID": 1, "otherID":5, "readedID":5]]
//
//    var noReadMessageCount: [[Int: Int]] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("messageOverViewに移動しました")
        
        self.readOverviewUsers(userID: 1)
        print(self.userDataJSON)
        
        self.tableView.separatorColor = UIColor(red: 188.0 / 255.0, green: 154.0 / 255.0, blue: 101.0 / 255.0, alpha: 1.0)
        self.tableView.rowHeight = 117
        
        
        
        // udに保存しておいた自分のユーザーidを取り出す
        let myUserID = UserDefaults.standard.integer(forKey: "myUserID")
        
        // udの中のメッセージ閲覧情報を参照して新着メッセージの個数、ユーザー名、時間を取ってきてる関数
//        getFavoUserData(userID: myUserID, messageID: 1)
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    // 改良版情報取得関数
    func readOverviewUsers(userID: Int)
    {
        AF.request("\(self.ipStr)messageOverView.php",
                   method: .post,
                   parameters: ["userDataJSON": self.userDataJSON],
//                   parameters: ["userDataJSON": self.cullentReadDict],
                   encoding: JSONEncoding.default,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
        .response
        { res in
            print(String(data: res.data!, encoding: .utf8)!)
            if let resData = res.data
            {
                print(JSON(resData))
                self.resUserInfo = JSON(resData)
                
                print(self.resUserInfo)
                
                self.tableView.reloadData()
            }
        }
    }
    
    // ユーザー名の個数だけセルを作る
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        self.resUserInfo.count
    }
    
    // セルに画像、テキストなどを代入している
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let identifier = "cell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if (cell == nil)
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        
        if let userIcon = cell?.contentView.viewWithTag(1) as? UIImageView
        {
            userIcon.sd_setImage(with: URL(string: "\(self.ipStr)\(self.resUserInfo[indexPath.row]["icon_img_url"])"))
        }
        if let userNameLabel = cell?.contentView.viewWithTag(2) as? UILabel
        {
            userNameLabel.text = self.resUserInfo[indexPath.row]["user_name"].stringValue
        }
        if let receivedTimeLabel = cell?.contentView.viewWithTag(3) as? UILabel
        {
            let receivedTime = self.resUserInfo[indexPath.row]["elapsed_time"].stringValue
            receivedTimeLabel.text = "\(receivedTime)分前"
        }
        if let newMessageLabel = cell?.contentView.viewWithTag(4) as? UILabel
        {
            newMessageLabel.text = self.resUserInfo[indexPath.row]["last_message"].stringValue
        }
        if let testlabel = cell?.contentView.viewWithTag(5) as? UILabel
        {
            let messageCountNum = self.resUserInfo[indexPath.row]["unread_count"].stringValue
            
            if messageCountNum == "0"
            {
                testlabel.isHidden = true
            }else{testlabel.isHidden = false}
            testlabel.layer.cornerRadius = 20.0      // 角の半径
            testlabel.clipsToBounds = true
            testlabel.text = messageCountNum
        }
        
        return cell!
    }
    
    // セルが選択されたとき変数segueValueに相手のidを代入して画面遷移する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.moveMessageID = self.resUserInfo[indexPath.row]["user_id"].stringValue
        
        performSegue(withIdentifier: "performMessage", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // 画面遷移する直前にShinMessageViewControllerのuserID,otherIDにそれぞれ自分のid、相手のidを代入する
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let nextViewController = segue.destination as? ShinMessageViewController

        nextViewController?.userID = String(UserDefaults.standard.integer(forKey: "myUserID"))
        nextViewController?.otherID = self.moveMessageID
    }
}
