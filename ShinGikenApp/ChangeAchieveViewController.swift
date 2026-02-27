//
//  ChangeAchieveViewController.swift
//  ShinGikenApp
//
//  Created by 山﨑貴史 on 2026/01/21.
//

import UIKit

class ChangeAchieveViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var collectionview: UICollectionView!
    
    @IBOutlet weak var preAchieveLabel: UILabel!
    @IBOutlet weak var selectedAchieveLabel: UILabel!
    
    var achievementArray:[String] = ["test1","test2","test3"]
    var selectedAchievement = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if var myUserData = UserDefaults.standard.dictionary(forKey: "myData") as? [String:Any]
        {
            guard let nowAchievement = myUserData["achievementName"] as? String else{return}
            self.selectedAchievement = nowAchievement
            self.preAchieveLabel.text = nowAchievement
        }
        
        
        if let achievementArray = UserDefaults.standard.array(forKey: "haveAchieve") as? [String]
        {
            self.achievementArray = achievementArray
            
            collectionview.reloadData()
            print("リロードしました")
        }else{print("nilが入ってます")}
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Basic-Cell", for: indexPath)
        
//        cell.backgroundColor = UIColor.red
        cell.layer.cornerRadius = 20.0
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.green.cgColor
        
        if let label = cell.contentView.viewWithTag(1) as? UILabel
        {
            label.text = self.achievementArray[indexPath.row]
            
//            let rgba = UIColor(red: 1.0, green: 127/255.0, blue: 161/255.0, alpha: 1.0)
//            label.backgroundColor = rgba    // 背景色
//            label.textColor = UIColor.white // 文字色
//            label.layer.cornerRadius = 10.0  // 角丸のサイズ
//            label.clipsToBounds = true      // labelの時は必須（角丸）

//            label.layer.borderWidth = 0.0   // 枠線の幅（0なので表示なし）
//            label.layer.borderColor = UIColor.white.cgColor // 枠線の色
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.achievementArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 42)  // 好きなサイズ
    }
    
    
    @IBAction func moveChangeAchieveBtn(_ sender: Any)
    {
        if var myUserData = UserDefaults.standard.dictionary(forKey: "myData") as? [String:Any]
        {
            print(myUserData)
            myUserData["achievementName"] = self.selectedAchievement
            print("achievementName変更しました")
            print(myUserData)
            
            UserDefaults.standard.set(myUserData, forKey: "myData")
        }else{}
        
        
        performSegue(withIdentifier: "performMypage", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        print(indexPath.row)
        
        self.selectedAchievement = self.achievementArray[indexPath.row]
        self.selectedAchieveLabel.text = self.selectedAchievement
    }

}
