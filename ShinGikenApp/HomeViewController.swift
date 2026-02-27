//
//  HomeViewController.swift
//  ShinGikenApp
//
//  Created by 山﨑貴史 on 2026/01/06.
//

import UIKit
import Alamofire
import SwiftyJSON

// imageResponse.php

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    let ipStr = ShareData.shared.IP
    
    var segueIntValue = 0
    
    @IBOutlet weak var todayStayTime: UILabel!
    
    var favoUsers:[[String: Int]] = []
    
    var resFavoData:[[String:Any]] = []
    var resStayData:[[String:Any]] = []
    var resRankData:[[String:Any]] = []
	
	var myUserID = -1
    
    @IBOutlet weak var tableView: UITableView!
    
    let sectionTitles = ["現在利用しているユーザー","ウォッチングリスト","コワーキング利用ランキング"]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 88
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.object(forKey: "myUserID") == nil
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
            vc?.modalPresentationStyle = .fullScreen
            self.present(vc!, animated: true)
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // ウォッチングリストユーザーIDと自分のユーザーIDをudから取ってくる
        if let savedFavoUsers = UserDefaults.standard.array(forKey: "favoUserID") as? [[String: Int]]
        {
            self.favoUsers = savedFavoUsers
        }
		self.myUserID = UserDefaults.standard.integer(forKey: "myUserID")
//        print("自分のid")
//        print(myUserID)
        
        // 滞在中のユーザー情報を取る
        nowStayUserData()
        // ウォッチングリスト入りしているユーザー情報を取る
        print("ウォッチングリスト表示")
        print(self.favoUsers)
        getFavoUserData(userID: self.favoUsers)
        // 滞在時間トップ3を取る
        getStayTimeRank()
        
        tableView.reloadData()
    }
    
    @IBAction func moveQRReadBtn(_ sender: Any)
    {
        performSegue(withIdentifier: "performQRRead", sender: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        // セクションの数を入れる
        return self.sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        //セクションのタイトルを設定する。
        return self.sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView()
        if section == 0
        {
            headerView.backgroundColor = UIColor(
                red: 47/255,
                green: 43/255,
                blue: 42/255,
                alpha: 1.0
            )
            headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 34)
            
            let title = UILabel()
            title.text = self.sectionTitles[section]
            title.font = UIFont(name: "LINESeedJPApp_OTF-Bold", size: 20)
            title.textColor = .white
            title.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            title.sizeToFit()
            headerView.addSubview(title)
            
            title.translatesAutoresizingMaskIntoConstraints = false
            title.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
            title.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
        }else
        if section == 1
        {
            headerView.backgroundColor = UIColor(
                red: 47/255,
                green: 43/255,
                blue: 42/255,
                alpha: 1.0
            )
            headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 34)
            
            let title = UILabel()
            title.text = self.sectionTitles[section]
            title.font = UIFont(name: "LINESeedJPApp_OTF-Bold", size: 20)
            title.textColor = .white
            title.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            title.sizeToFit()
            headerView.addSubview(title)
            
            title.translatesAutoresizingMaskIntoConstraints = false
            title.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
            title.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
        }else
        if section == 2{}
        
        return headerView
    }

    // セクションごとにセルの数を設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            // 今いる人の数を返す
            return self.resStayData.count
        }else if section == 1
        {
            print("セルの個数を決めるところです")
            print(self.resFavoData.count)
            print(self.resFavoData)
            // ウォッチングリストに入っている人の数を返す
            return self.resFavoData.count
            
        }else if section == 2
        {
            return 1
        }else {return 0}
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section != 2
        {
            return 98
        }else if indexPath.section == 2
        {
            return 182
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var identifier = ""
        
        if indexPath.section != 2
        {
            identifier = "cell"
        }else if indexPath.section == 2
        {
            identifier = "rankingCell"
        }
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if identifier == "rankingCell"
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "rankingCell", for: indexPath)
            cell?.selectionStyle = .none
        }
        
        let clearView = UIView()
        clearView.backgroundColor = .clear
        cell?.selectedBackgroundView = clearView
        
        if (cell == nil)
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        
        if indexPath.section == 0
        {
            // labelにテキストを設定
            if let label = cell?.contentView.viewWithTag(1) as? UILabel
            {
                label.text = self.resStayData[indexPath.row]["userName"] as! String
            }
            if let label = cell?.contentView.viewWithTag(3) as? UILabel
            {
                label.text = self.resStayData[indexPath.row]["achievementName"] as? String
                label.sizeToFit()
                
                // 角丸
                label.layer.cornerRadius = 10
                label.layer.masksToBounds = true // 角丸を適用するため必須
                        
                // 枠線
                label.layer.borderWidth = 2
                label.layer.borderColor = UIColor(red: 1.0, green: 0.8, blue: 0.4745, alpha: 1.0).cgColor
                        
//                self.view.addSubview(label)
            }
            if let label = cell?.contentView.viewWithTag(4) as? UILabel
				,let todayStayTime = self.resStayData[indexPath.row]["diff_hours"] as? Int
            {
                label.text = "\(todayStayTime)時間"
            }
            
            // imageViewに画像を設定
            if let image = cell?.contentView.viewWithTag(2) as? UIImageView
            {
                if let imageName = self.resStayData[indexPath.row]["imageURL"]as? String
                {
                    let imageURL = URL(string: "\(self.ipStr)uploads/\(imageName)")
                    image.sd_setImage(with: imageURL)
                }
            }
            if let image = cell?.contentView.viewWithTag(5) as? UIImageView
            {
                let studentFlagInt = self.resStayData[indexPath.row]["studentFlag"] as? Int
                if(studentFlagInt == 1)
                {
                    image.image = UIImage(named: "tempStudentIcon.png")
                }else
                {
                    image.image = nil
                }
            }
        }else if indexPath.section == 1
        {
            // labelにテキストを設定
            if let label = cell?.contentView.viewWithTag(1) as? UILabel
            {
                label.text = self.resFavoData[indexPath.row]["userName"] as! String
            }
            if let label = cell?.contentView.viewWithTag(3) as? UILabel
            {
                label.text = self.resFavoData[indexPath.row]["achievementName"] as! String
                label.sizeToFit()
                
                let padding: CGFloat = 4.0
                label.frame = CGRect(
                    x: label.frame.origin.x - padding,
                    y: label.frame.origin.y - padding,
                    width: label.frame.size.width + padding * 2,
                    height: label.frame.size.height + padding * 2
                )
                
                label.layer.borderWidth = 1.0    // 枠線の幅
                label.layer.borderColor = UIColor(red: 1.0, green: 0.8, blue: 0.4745, alpha: 1.0).cgColor
            }
            if let label = cell?.contentView.viewWithTag(4) as? UILabel,let todayStayTime = self.resFavoData[indexPath.row]["diff_hours"] as? Int
            {
                label.text = "\(todayStayTime)時間"
            }
            
            // imageViewに画像を設定
            if let image = cell?.contentView.viewWithTag(2) as? UIImageView
            {
                if let imageName = self.resFavoData[indexPath.row]["imageURL"]as? String
                {
                    let imageURL = URL(string: "\(self.ipStr)uploads/\(imageName)")
                    image.sd_setImage(with: imageURL)
                }
            }
            if let image = cell?.contentView.viewWithTag(5) as? UIImageView
            {
                let studentFlagInt = self.resFavoData[indexPath.row]["studentFlag"] as? Int
                if(studentFlagInt == 1)
                {
                    image.image = UIImage(named: "tempStudentIcon.png")
                }else
                {
                    image.image = nil
                }
            }
        }else if indexPath.section == 2
        {
            if !self.resRankData.isEmpty
            {
                if let label = cell?.contentView.viewWithTag(1) as? UILabel
                {
                    label.text = self.resRankData[0]["user_name"] as? String
                }
                if let label = cell?.contentView.viewWithTag(2) as? UILabel
                {
                    label.text = self.resRankData[1]["user_name"] as? String
                }
                if let label = cell?.contentView.viewWithTag(3) as? UILabel
                {
                    label.text = self.resRankData[2]["user_name"] as? String
                }
                
                if let image = cell?.contentView.viewWithTag(4) as? UIImageView
                {
                    if let imageName = self.resRankData[0]["image_url"]
                    {
                        if let imageURL = URL(string: "\(self.ipStr)uploads/\(imageName)")
                        {
                            image.sd_setImage(with: imageURL)
                        }
                    }
                }
                if let image = cell?.contentView.viewWithTag(5) as? UIImageView
                {
                    if let imageName = self.resRankData[1]["image_url"]
                    {
                        if let imageURL = URL(string: "\(self.ipStr)uploads/\(imageName)")
                        {
                            image.sd_setImage(with: imageURL)
                        }
                    }
                }
                if let image = cell?.contentView.viewWithTag(6) as? UIImageView
                {
                    if let imageName = self.resRankData[2]["image_url"]
                    {
                        if let imageURL = URL(string: "\(self.ipStr)uploads/\(imageName)")
                        {
                            image.sd_setImage(with: imageURL)
                        }
                    }
                }
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.section == 0
        {
            let selectedID = self.resStayData[indexPath.row]["users_id"]
            
            self.segueIntValue = selectedID as! Int
            
            performSegue(withIdentifier: "performOtherPage", sender: nil)
        }else if indexPath.section == 1
        {
            let selectedID = self.resFavoData[indexPath.row]["users_id"]
            self.segueIntValue = selectedID as! Int
            performSegue(withIdentifier: "performOtherPage", sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func nowStayUserData()
    {
		print("\(self.ipStr)resNowStayUser.php")
		
        AF.request("\(self.ipStr)resNowStayUser.php",
                   method: .get,
                   parameters: nil,
				   encoding: URLEncoding.default,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
        .responseJSON { res in

			
			if let data = res.data
			{
				let json = JSON(data)
				
//				print(json)
				
				guard let responseJSON = json.arrayObject as? [[String: Any]] else {return}
				self.resStayData = responseJSON
				
				print("滞在ユーザー情報")
				print(self.resStayData)
				
				for user in self.resStayData
				{
					if (user["users_id"] as! Int == self.myUserID)
					{
						self.todayStayTime.isHidden = false
						self.todayStayTime.text = "\(user["diff_hours"] as! Int)時間"
					}
				}
				
				DispatchQueue.main.async{
					self.tableView.reloadData()
				}
			}
        }
    }
    
    func getFavoUserData(userID: [[String:Int]])
    {
        let jsonData = try? JSONSerialization.data(withJSONObject: userID, options: [.prettyPrinted])
        AF.request("\(self.ipStr)gikenMySQLTest.php",
                   method: .post,
                   parameters: ["favoUsers": userID],
                   encoding: JSONEncoding.default,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
        .response
        {response in
            guard let JSONData = response.data else{return}
            let testData = JSON(JSONData)
            
            guard let responseJSON = testData.arrayObject as? [[String: Any]] else {return}
            self.resFavoData = responseJSON
            
            print("responseを受け取ったあたりです")
            print(self.resFavoData)
            
            self.tableView.reloadData()
        }
    }
    
    func getStayTimeRank()
    {
        AF.request("\(self.ipStr)getStayTimeRank.php",
                   method: .post,
                   parameters: nil,
                   encoding: JSONEncoding.default,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
        .response
        {response in
            
            guard let JSONData = response.data else{return}
            print(String(data: JSONData, encoding: .utf8) ?? "no data")
            let testData = JSON(JSONData)
            guard let responseJSON = testData.arrayObject as? [[String: Any]] else {return}
            
            self.resRankData = responseJSON
            
            print(self.resRankData)
            
            self.tableView.reloadData()
            self.tableView.reloadSections(IndexSet(integer: 2), with: .none)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let nextViewController = segue.destination as? OtherUserPageViewController
        
        print("ホームビューから値を書き込みます")
        print(self.segueIntValue)
        nextViewController?.userID = String(self.segueIntValue)
    }
}
