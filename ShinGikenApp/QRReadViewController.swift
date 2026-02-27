//
//  QRReadViewController.swift
//  ShinGikenApp
//
//  Created by 山﨑貴史 on 2026/01/06.
//

import UIKit
import AVFoundation
import SwiftyJSON
import Alamofire

class QRReadViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate
{
    let ipStr = ShareData.shared.IP
    
    
    var captureSession : AVCaptureSession?
    var videoLayer : AVCaptureVideoPreviewLayer?
    var isbn : String?

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func startCapture()
    {
        let session = AVCaptureSession()
        guard let device : AVCaptureDevice = AVCaptureDevice.default(for: .video)else{return}
        guard let input : AVCaptureInput = try? AVCaptureDeviceInput(device: device)else{return}
        let output = AVCaptureMetadataOutput()
        
        session.addInput(input)
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.qr]
        
        session.startRunning()
        
        let videoLayer = AVCaptureVideoPreviewLayer(session: session)
        videoLayer.videoGravity = .resizeAspectFill
        videoLayer.frame = self.view.bounds
        
        self.videoLayer = videoLayer
        self.view.layer.addSublayer(videoLayer)
        
        self.captureSession = session
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.startCapture()
        print("DidAppearFinish!")
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection)
    {
        //バーコードが検出されたら呼び出される
        for metadataObject in metadataObjects
        {
            print("データを検出しました")
            guard self.videoLayer?.transformedMetadataObject(for: metadataObject) is AVMetadataMachineReadableCodeObject else { continue }
            guard let object = metadataObject as? AVMetadataMachineReadableCodeObject else
            {
                continue
            }
            guard let detectionString = object.stringValue else
            {
                continue
            }
            
            print(detectionString)
            
            // jsonをチェックし、不正なデータを読まないようにする
            if let data = detectionString.data(using: .utf8)
            {
                let json = JSON(data)
                if json["type"].string == "event"
                {
                    let eventName = json["name"].stringValue
//                    let eventDate = json["date"].stringValue
                    print(eventName)
                    
                    guard let myUserID = UserDefaults.standard.dictionary(forKey: "myData")?["myID"]
                    else {
                        return
                    }
                    print(myUserID)
                    
                    
                    self.captureSession?.stopRunning()
                    self.captureSession = nil
                    
                    self.uploadEventData(eventName: eventName, userID: myUserID as! Int)
                    
                    dismiss(animated: true)
                }
            }
        }
    }
    
    func uploadEventData(eventName: String, userID: Int)
    {
        print("uploadEventData呼び出された")
        
        let url = "\(self.ipStr)saveEventInfo.php"
        
        AF.request(url,
                   method: .post,
                   parameters: ["userID": userID, "eventName": eventName],
                   encoding: URLEncoding.httpBody,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
        .response{
            response in
            if let responseData = response.data
            {
                print(String(data: responseData, encoding: .utf8)!)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        self.captureSession?.stopRunning()
        self.captureSession = nil
    }
}
