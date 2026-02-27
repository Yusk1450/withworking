//
//  MyPageViewController.swift
//  ShinGikenApp
//
//  Created by 山﨑貴史 on 2026/01/06.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class MyPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    let ipStr = ShareData.shared.IP
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var studentImageView: UIImageView!
    
    @IBOutlet weak var nowWeekTimeLabel: UILabel!
    @IBOutlet weak var preWeekTimeLabel: UILabel!
    @IBOutlet weak var sumWeekTimeLabel: UILabel!
    
    @IBOutlet weak var lastTimeLabel: UILabel!
    @IBOutlet weak var prevTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var eventTableTitle: UILabel!
    
    @IBOutlet weak var achieveChangeBtn: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var myUserData = UserDefaults.standard.dictionary(forKey: "myData")
    
    var tableArray = UserDefaults.standard.array(forKey: "eventName") ?? []
    var eventDayArray = UserDefaults.standard.array(forKey: "eventName") ?? []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        postMyData()
        guard let myFavoAchievement = self.myUserData?["achievementName"]as? String else{return}
        guard let myName = self.myUserData?["userName"]as? String else{return}
        
        self.achieveChangeBtn.setTitle(myFavoAchievement, for: .normal)
        self.userNameLabel.text = myName
        self.userNameLabel.sizeToFit()
        let StudentImgPos = self.userNameLabel.frame.origin.x + self.userNameLabel.frame.size.width + 10
        self.studentImageView.frame.origin.x = StudentImgPos
        
        // ラベル装飾設定
        self.nowWeekTimeLabel.layer.cornerRadius = 5.0
        self.nowWeekTimeLabel.clipsToBounds = true
        self.preWeekTimeLabel.layer.cornerRadius = 5.0
        self.preWeekTimeLabel.clipsToBounds = true
        self.sumWeekTimeLabel.layer.cornerRadius = 5.0
        self.sumWeekTimeLabel.clipsToBounds = true
        
        self.eventTableTitle.layer.borderWidth = 1.0
        self.eventTableTitle.layer.borderColor = UIColor(red: 188.0 / 255.0, green: 154.0 / 255.0, blue: 101.0 / 255.0, alpha: 1.0).cgColor
        self.eventTableTitle.layer.cornerRadius = 20.0
        self.eventTableTitle.clipsToBounds = true
        
        self.tableView.rowHeight = 88
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.tableArray.count
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
            label.text = self.tableArray[indexPath.row] as! String
        }
        if let label = cell?.contentView.viewWithTag(2) as? UILabel
        {
            
            label.text = self.eventDayArray[indexPath.row] as! String
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
//        self.text = self.tableArray[indexPath.row]
//        performSegue(withIdentifier: "nextView", sender: nil)
//        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.selectionStyle = .none // 選択時のハイライトを消す
    }
    
    @IBAction func changeAchieveBtn(_ sender: Any)
    {
        performSegue(withIdentifier: "performChangeAchieve", sender: nil)
    }
    
    func imageRequest(userID: Int)
    {
        AF.request("\(self.ipStr)resIconImg.php",
                   method: .post,
                   parameters: ["userID": userID],
                   encoding: URLEncoding.default,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
        .responseString
        { res in
            guard let fileName = res.value else{return}
            
            self.iconImageView.sd_setImage(with: URL(string: "\(self.ipStr)uploads/\(fileName)"), completed: nil)
        }
    }
    
    func postMyData()
    {
        print(myUserData?["myID"])
        let userID = myUserData?["myID"]
        AF.request("\(self.ipStr)postMyData.php",
                   method: .post,
                   parameters: ["userID": userID],
                   encoding: URLEncoding.default,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
        .response
        { response in
            guard let JSONData = response.data else{return}
            let testData = JSON(JSONData)
            let myData = testData[0]
            print(testData)
            
            print("myDataをプリントします")
            print(myData)
            
            if myData["studentFlag"] == 1
            {
                self.studentImageView.image = UIImage(named: "studentImg")
            }
            self.userNameLabel.text = myData["userName"].stringValue
            self.userNameLabel.sizeToFit()
            let StudentImgPos = self.userNameLabel.frame.origin.x + self.userNameLabel.frame.size.width + 10
            self.studentImageView.frame.origin.x = StudentImgPos
            
            self.lastTimeLabel.text = "\(myData["last_7d_hours"])時間\(myData["last_7d_minutes"])分"
            self.prevTimeLabel.text = "\(myData["prev_7d_hours"])時間\(myData["prev_7d_minutes"])分"
            self.totalTimeLabel.text = "\(myData["total_hours"])時間\(myData["total_minutes_only"])分"
            
            self.iconImageView.sd_setImage(with: URL(string: "\(self.ipStr)uploads/\(myData["imageURL"])"), completed: nil)
            
            print("readEventData関数呼び出し直前")
            self.readEventData(userID: myData["id"].intValue)
        }
    }
    
    func readEventData(userID: Int)
    {
        print("readEventData関数到達")
        AF.request("\(self.ipStr)readEventInfo.php",
                   method: .post,
                   parameters: ["userID": userID],
                   encoding: URLEncoding.httpBody,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
        .response
        { res in
            
            self.tableArray = []
            self.eventDayArray = []
            if let resData = res.data
            {
                print(JSON(resData))
                
                for i in JSON(resData).arrayValue
                {
                    self.tableArray.append(i["event_name"].stringValue)
                    self.eventDayArray.append(i["event_date"].stringValue)
                }
//                self.tableArray = JSON(resData)["event_name"].arrayValue
                
                print(self.tableArray)
                print(self.eventDayArray)
                
                self.tableView.reloadData()
            }
        }
    }
}
