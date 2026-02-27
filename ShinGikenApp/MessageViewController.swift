//
//  MessageViewController.swift
//  ShinGikenApp
//
//  Created by 山﨑貴史 on 2026/01/16.
//

import UIKit
import SwiftyJSON
import Alamofire
import SDWebImage

class MessageViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource
{
    let ipStr = ShareData.shared.IP
    
    var myUserID = 0
    let receiverID = 3 //送信テスト用の仮データ
    
    @IBOutlet weak var messageInputField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var messageJSON = JSON()
    
    var timer = Timer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.messageInputField.delegate = self
        
        // 自分のユーザーIDをudから取ってくる
        if let myUserData = UserDefaults.standard.dictionary(forKey: "myData") as? [String:Any]
        {
            guard let myID = myUserData["myID"]as? Int else {return}
            self.myUserID = myID
            print(self.myUserID)
        }
        
        // 1秒おきにメッセージの取得を行う
        self.timer = Timer.scheduledTimer(withTimeInterval: 5,
                                        repeats: true,
                                        block:
            { (time:Timer) in
            self.checkReceiveMessage()
            }
        )
    }
    
    // セルの数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.messageJSON.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if (cell == nil)
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        
        if self.messageJSON[indexPath.row]["senderID"].intValue == self.myUserID
        {
            if let leftLabel = cell?.contentView.viewWithTag(1) as? UILabel
            {
                leftLabel.text = nil
            }
            if let rightLabel = cell?.contentView.viewWithTag(3) as? UILabel
            {
                print(self.messageJSON[indexPath.row])
                rightLabel.text = self.messageJSON[indexPath.row]["messageValue"].stringValue
            }
            if let leftImage = cell?.contentView.viewWithTag(2) as? UIImageView
            {
                leftImage.image = nil
            }
            if let rightImage = cell?.contentView.viewWithTag(4) as? UIImageView
            {
                rightImage.sd_setImage(with: URL(string: "\(self.ipStr)uploads/\(self.messageJSON[indexPath.row]["senderImageURL"].stringValue)"), completed: nil)
            }
        }else
        {
            if let leftLabel = cell?.contentView.viewWithTag(1) as? UILabel
            {
                leftLabel.text = self.messageJSON[indexPath.row]["messageValue"].stringValue
            }
            if let leftImage = cell?.contentView.viewWithTag(2) as? UIImageView
            {
                leftImage.sd_setImage(with: URL(string: "\(self.ipStr)\(self.messageJSON[indexPath.row]["senderImageURL"].stringValue)"), completed: nil)
            }
            if let rightLabel = cell?.contentView.viewWithTag(3) as? UILabel
            {
//                print(self.messageJSON[indexPath.row])
                rightLabel.text = nil
            }
            if let rightImage = cell?.contentView.viewWithTag(4) as? UIImageView
            {
                rightImage.image = nil
            }
        }
        return cell!
    }
    
    // 選択された後に表示を元に戻す
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // メッセージをサーバーに送る
    @IBAction func sendMessageBtn(_ sender: Any)
    {
        guard let messageValue = messageInputField.text else{return}
        sendMessageAF(senderID: self.myUserID, receiverID: self.receiverID, value: messageValue)
        print("sendBtnPressed!")
    }
    
    // 送受信したメッセージをJSONに取り込む
    func checkReceiveMessage()
    {
        AF.request("\(self.ipStr)messageReceive.php",
                   method: .post,
                   parameters: ["senderID": self.myUserID, "receiverID": self.receiverID],
                   encoding: JSONEncoding.default,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
        .response
        {response in
            guard let JSONData = response.data else{return}
            guard let printJSONData = String(data: JSONData, encoding: .utf8) else{return}
            
            let testData = JSON(JSONData)
            
            self.messageJSON = testData
            
            print(printJSONData)
            
            self.tableView.reloadData()
        }
    }
    
    func sendMessageAF(senderID: Int, receiverID: Int, value: String)
    {
        AF.request("\(self.ipStr)messageSendTest.php",
                   method: .post,
                   parameters: ["senderID": senderID, "receiverID": receiverID, "messageValue": value],
                   encoding: JSONEncoding.default,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
        .response
        {response in
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder() // キーボードを閉じる
        return true
    }
}
