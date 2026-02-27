//
//  OtherUserPageViewController.swift
//  ShinGikenApp
//
//  Created by 山﨑貴史 on 2026/01/28.
//

import UIKit
import SwiftyJSON
import Alamofire

class OtherUserPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    
    var userID:String?
    var otherID:String?
    let ipStr = ShareData.shared.IP
    
    var favoUsers:[[String: Int]] = []
    
    
    @IBOutlet weak var studentImageView: UIImageView!
    @IBOutlet weak var lastTimeLabel: UILabel!
    @IBOutlet weak var prevTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var addWatchBtn: UIButton!
    @IBOutlet weak var eventTopLabel: UILabel!
    @IBOutlet weak var continuationLabel: UILabel!
    
    var isfavo = false
    
    var eventList = [[String:String]]()
	
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.postMyData()
        tableView.separatorStyle = .none
        
        if let savedFavoUsers = UserDefaults.standard.array(forKey: "favoUserID") as? [[String: Int]]
        {
            self.favoUsers = savedFavoUsers
            print("favoUserプリント")
            print(self.favoUsers)
        }
        
        eventTopLabel.layer.borderWidth = 1
        eventTopLabel.layer.borderColor = UIColor(red: 188/255, green: 154/255, blue: 101/255, alpha: 1.0).cgColor

    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
		return self.eventList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 74
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let identifier = "Cell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        cell?.selectionStyle = .none
        
        if (cell == nil)
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        
//        cell?.textLabel?.text = self.tableArray[indexPath.row] as! String
        
        if let label = cell?.contentView.viewWithTag(1) as? UILabel
        {
			label.text = self.eventList[indexPath.row]["event_name"]
        }
        if let label = cell?.contentView.viewWithTag(2) as? UILabel
        {
            if let eventDate = self.eventList[indexPath.row]["event_date"] as? String {
                label.text = "\(eventDate) 開催！"
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
//        self.text = self.tableArray[indexPath.row]
//        performSegue(withIdentifier: "nextView", sender: nil)
//        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func performMessage(_ sender: Any)
    {
        performSegue(withIdentifier: "userPageToMessage", sender: nil)
    }
    
    @IBAction func addWatchListBtn(_ sender: Any)
    {
        print("ウォッチングリストボタン押されました")
        if let savedFavoUsers = UserDefaults.standard.array(forKey: "favoUserID") as? [[String: Int]]
        {
            self.favoUsers = savedFavoUsers
            print("favoUserプリント")
            print(self.favoUsers)
            
            if var config = self.addWatchBtn.configuration {
                print("コンフィグのif文の中身です")
                
                if isfavo
                {
                    let newUserID = Int(userID!)!
                    self.favoUsers.append(["favoUserID": newUserID])
                    UserDefaults.standard.set(self.favoUsers, forKey: "favoUserID")
                    print("保存します")
                    
                    
                    print(self.favoUsers)
                    print("保存しました")
                    config.image = UIImage(named: "listOut")
                    isfavo = false
                }else if !isfavo
                {
                    let newUserID = Int(userID!)!
                    
                    self.favoUsers.removeAll
                    { dict in
                        dict["favoUserID"] == newUserID
                    }
                    print("削除しました")
                    print(self.favoUsers)
                    UserDefaults.standard.set(self.favoUsers, forKey: "favoUserID")
                    config.image = UIImage(named: "listIn")
                    isfavo = true
                }

                let storyboardFont = self.addWatchBtn.titleLabel?.font

                config.titleTextAttributesTransformer =
                    UIConfigurationTextAttributesTransformer { incoming in
                        var outgoing = incoming
                        outgoing.font = storyboardFont
                        return outgoing
                    }

                self.addWatchBtn.configuration = config
            }
        }else{print(UserDefaults.standard.array(forKey: "favoUserID")!)}
    }
    
    @IBAction func BackBtn(_ sender: Any)
    {
        print("dismiss")
        self.dismiss(animated: true)
    }
    
    func postMyData()
    {
        print("postMydataが実行されました")
//        let userID = UserDefaults.standard.integer(forKey: "myUserID")
        let userID = Int(userID!)
        
        
        AF.request("\(self.ipStr)postMyData.php",
                   method: .post,
                   parameters: ["userID": userID],
                   encoding: URLEncoding.default,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
        .response
        { response in
            
            print("postMyDataのレスポンスがきました")
            guard let JSONData = response.data else{return}
            let testData = JSON(JSONData)
            let myData = testData[0]
            
            print(myData)
            self.userID = myData["id"].stringValue
            
            if myData["studentFlag"] == 1
            {
                self.studentImageView.image = UIImage(named: "tempStudentIcon")
            }
            self.lastTimeLabel.text = "\(myData["last_7d_hours"])時間\(myData["last_7d_minutes"])分"
            self.prevTimeLabel.text = "\(myData["prev_7d_hours"])時間\(myData["prev_7d_minutes"])分"
            self.totalTimeLabel.text = "\(myData["total_hours"])時間\(myData["total_minutes_only"])分"
            
            self.userNameLabel.text = "\(myData["userName"])"
            self.userNameLabel.sizeToFit()
            let StudentImgPos = self.userNameLabel.frame.origin.x + self.userNameLabel.frame.size.width + 10
            self.studentImageView.frame.origin.x = StudentImgPos
            
            self.iconImageView.sd_setImage(with: URL(string: "\(self.ipStr)uploads/\(myData["imageURL"])"), completed: nil)
            self.iconImageView.frame.size.width = 80
            self.iconImageView.frame.size.height = 80
            
			self.eventList = myData["events"].arrayValue.compactMap { $0.dictionaryObject as? [String: String] }
            self.tableView.reloadData()
            
            if let savedFavoUsers = UserDefaults.standard.array(forKey: "favoUserID") as? [[String: Int]]
            {
                self.favoUsers = savedFavoUsers
                print("favoUserプリント")
                print(self.favoUsers)
                
                if self.favoUsers.contains(["favoUserID": userID!])
                {
                    print("すでに登録されています")
                    
                    if var config = self.addWatchBtn.configuration {
                        print("コンフィグのif文の中身です")

                        config.image = UIImage(named: "listOut")
                        let storyboardFont = self.addWatchBtn.titleLabel?.font

                        config.titleTextAttributesTransformer =
                            UIConfigurationTextAttributesTransformer { incoming in
                                var outgoing = incoming
                                outgoing.font = storyboardFont
                                return outgoing
                            }

                        self.addWatchBtn.configuration = config
                    }
                }else {print("まだ登録されていません")}
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let nextViewController = segue.destination as? ShinMessageViewController

        nextViewController?.userID = String(UserDefaults.standard.integer(forKey: "myUserID"))
        nextViewController?.otherID = self.userID
    }
    

}
