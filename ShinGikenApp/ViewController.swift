//
//  ViewController.swift
//  ShinGikenApp
//
//  Created by 山﨑貴史 on 2026/01/03.
//
//ロケーションは技研にいる時間をとるため
//毎回アカウントを作る必要はないため、ホームスタートにする
//そのため、ロケーションはホームで行う

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    let ipStr = ShareData.shared.IP
    
    let locationManager = CLLocationManager()
    var lat:CLLocationDegrees?// 緯度
    var lon:CLLocationDegrees?// 経度
    
    var studentFlag = true
    
    
    @IBOutlet weak var nickNameInputField: UITextField!
    
    @IBOutlet weak var userIconImage: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
		
//		UserDefaults.standard.set(35, forKey: "myUserID")
        
        // 仮のウォッチングリストユーザー情報
        let favoUsers:[[String:Any]] = [["favoUserID": 2], ["favoUserID": 5]]
//        UserDefaults.standard.set(favoUsers, forKey: "favoUserID")
        UserDefaults.standard.set([], forKey: "favoUserID")
        // 仮のマイユーザー情報
        let myData = ["myID": 1,"userName": "ユーザー1","studentFlag": 1,"achievementName": "称号1"] as [String : Any]
        UserDefaults.standard.set(myData, forKey: "myData")
        // 取得アチーブメント一覧
        let haveAchieve = ["achievement1","achievement2","achievement3"]
        UserDefaults.standard.set(haveAchieve, forKey: "haveAchieve")
        
        
        self.nickNameInputField.delegate = self
        
        if (CLLocationManager.locationServicesEnabled())
        {
            self.locationManager.delegate = self
            self.locationManager.distanceFilter = kCLDistanceFilterNone
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    @IBAction func iconSelectBtn(_ sender: Any)
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        
        self.present(picker, animated: true)
    }
    // フォトライブラリから写真が選択された or 写真が撮影された
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            self.userIconImage.image = img
        }
        
        self.dismiss(animated: true)
    }
    
    @IBAction func jobSelectSegment(_ sender: UISegmentedControl)
    {
        print(sender.titleForSegment(at: sender.selectedSegmentIndex)!)
        
        if sender.titleForSegment(at: sender.selectedSegmentIndex)! == "学生"
        {
            self.studentFlag = true
        }else{self.studentFlag = false}
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)
    {
        let status = self.locationManager.authorizationStatus
        
        // ユーザーが許可していない場合
        if (status == .notDetermined)
        {
            // 許可を求める
            self.locationManager.requestWhenInUseAuthorization()
        }
        // 許可している場合
        else if (status == .authorizedWhenInUse)
        {
            self.locationManager.requestAlwaysAuthorization()
            // 位置情報の取得を開始する
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.last
        {
            self.lat = location.coordinate.latitude
            self.lon = location.coordinate.longitude
            
            if let lat = self.lat
            {
                if let lon = self.lon
                {
                    if 35.38901 <= lat && 35.38952 >= lat && 136.72270 <= lon && 136.72346 >= lon
                    {
                        print("コワーキングスペースに到着しました")
                    }
                }
            }
        }
    }

    @IBAction func nextBtn(_ sender: Any)
    {
        guard let nickName = nickNameInputField.text else{return}
        
        print(nickName)
        regiUserInfo(userName: nickName, studentFlag: self.studentFlag)
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.nickNameInputField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func tempImageReq(_ sender: Any)
    {
        imageRequest(userID: 2)
    }
    
    func imageRequest(userID: Int)
    {
        AF.request("\(self.ipStr)imageResponse.php",
                   method: .post,
                   parameters: ["userID": userID],
                   encoding: URLEncoding.default,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
        .response
        { res in
            guard let data = res.data else{return}
            print(data)
            let imageData = UIImage(data: data)
            
            print(imageData)
            
            self.userIconImage.image = imageData
            print(imageData)
        }
    }
    
    func uploadImageAF(userID: Int)
    {
        guard let imageData = self.userIconImage.image?.jpegData(compressionQuality:0.5)else{
            print("画像がありません")
            return}
        let url = "\(self.ipStr)imageTest.php"
        
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData, withName: "image", fileName: "\(userID).jpg", mimeType: "image/jpeg")
        }, to: url, method: .post).responseString
        {response in
            print(response)
        }
        print("画像アップロードしました")
    }
    
    func regiUserInfo(userName: String, studentFlag: Bool)
    {
        let url = "\(self.ipStr)userInfoRegi.php"
        
        AF.request(url,
                   method: .post,
                   parameters: ["userName": userName, "studentFlag": studentFlag],
                   encoding: URLEncoding.default,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
        .response{ [self]
            res in
            
            print("↓レスポンスプリント")
            if let resText = res.data
            {
                print(Int(String(data: resText, encoding: .utf8)!))
                
                // 一時的に無効化してid1に固定する
                let userID = Int(String(data: resText, encoding: .utf8)!)!
//                let userID = 1
                
                uploadImageAF(userID: userID)
                regiimageURL(userID: userID)
                
                UserDefaults.standard.set(userID, forKey: "myUserID")
                
                let myData = ["myID": userID,"userName": userName,"studentFlag": studentFlag,"achievementName": "称号1"] as [String : Any]
                UserDefaults.standard.set(myData, forKey: "myData")
            }
        }
    }
    
    func regiimageURL(userID: Int)
    {
        print("regiimageURLが動きました")
        let url = "\(self.ipStr)imageURLRegi.php"
        
        AF.request(url,
                   method: .post,
                   parameters: ["imageURL": "\(userID).jpg", "userID": userID],
                   encoding: URLEncoding.httpBody,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
        
        
            .response { response in
                self.performSegue(withIdentifier: "AcountCreated", sender: nil)
            }
    }
}

