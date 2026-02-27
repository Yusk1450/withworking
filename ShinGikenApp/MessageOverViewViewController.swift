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
    
	var resUserInfo = [[String:Any]]()
    
    let cullentReadDict: [String: Int] = UserDefaults.standard.dictionary(forKey: "currentReadDict") as? [String: Int] ?? [:]
	
	var senderID: Int?
	var senderName: String?
	var senderImageURL: String?
	
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.tableView.separatorColor = UIColor(red: 188.0 / 255.0, green: 154.0 / 255.0, blue: 101.0 / 255.0, alpha: 1.0)
        self.tableView.rowHeight = 117
    }
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)

		let userID = UserDefaults.standard.integer(forKey: "myUserID")
		print("userID: \(userID)")
		
		self.readOverviewUsers(userID: userID)
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
                   method: .get,
				   parameters: ["userID": userID],
                   encoding: URLEncoding.default,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
        .responseJSON { res in

			if let data = res.data
			{
				let json = JSON(data)
				
				print(json)
				
				self.resUserInfo = json.arrayObject as! [[String:Any]]
				
//				print(self.resUserInfo)
				
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
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
			if let imagePath = self.resUserInfo[indexPath.row]["imageURL"] as? String
			{
				print("\(self.ipStr)\(imagePath)")
				
				userIcon.sd_setImage(with: URL(string: "\(self.ipStr)uploads/\(imagePath)"))
			}
        }
        if let userNameLabel = cell?.contentView.viewWithTag(2) as? UILabel
        {
            userNameLabel.text = self.resUserInfo[indexPath.row]["userName"] as? String
        }
        if let receivedTimeLabel = cell?.contentView.viewWithTag(3) as? UILabel
        {
			if let receivedTime = self.resUserInfo[indexPath.row]["created_at"] as? String
			{
				receivedTimeLabel.text = self.timeAgoString(from: receivedTime)
			}
        }
        if let newMessageLabel = cell?.contentView.viewWithTag(4) as? UILabel
        {
            newMessageLabel.text = self.resUserInfo[indexPath.row]["messageValue"] as? String
        }
        if let testlabel = cell?.contentView.viewWithTag(5) as? UILabel
        {
            if let messageCountNum = self.resUserInfo[indexPath.row]["unread_count"] as? Int
			{
				if messageCountNum == 0
				{
					testlabel.isHidden = true
				}
				else
				{
					testlabel.isHidden = false
				}
				testlabel.layer.cornerRadius = 20.0      // 角の半径
				testlabel.clipsToBounds = true
				testlabel.text = messageCountNum.description
			}
        }
        
        return cell!
    }
    
    // セルが選択されたとき変数segueValueに相手のidを代入して画面遷移する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		self.senderID = self.resUserInfo[indexPath.row]["senderID"] as? Int
		self.senderName = self.resUserInfo[indexPath.row]["userName"] as? String
		self.senderImageURL = self.resUserInfo[indexPath.row]["imageURL"] as? String
		
        performSegue(withIdentifier: "performMessage", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func timeAgoString(from dateString: String) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "ja_JP")
        
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let seconds = Int(Date().timeIntervalSince(date))
        
        if seconds < 60 { return "たった今" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)分前" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)時間前" }
        let days = hours / 24
        if days < 30 { return "\(days)日前" }
        let months = days / 30
        if months < 12 { return "\(months)ヶ月前" }
        let years = months / 12
        return "\(years)年前"
    }
    
    // 画面遷移する直前にShinMessageViewControllerのuserID,otherIDにそれぞれ自分のid、相手のidを代入する
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
		if let senderID = self.senderID
		{
			let nextViewController = segue.destination as? ShinMessageViewController

			nextViewController?.userID = String(UserDefaults.standard.integer(forKey: "myUserID"))
			nextViewController?.otherID = String(senderID)
			nextViewController?.otherName = self.senderName
			nextViewController?.otherImageURL = self.senderImageURL
		}
		
    }
}
