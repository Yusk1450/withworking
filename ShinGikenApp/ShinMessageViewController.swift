import UIKit
import MessageKit
import InputBarAccessoryView
import Alamofire
import SwiftyJSON

class ShinMessageViewController: MessagesViewController
{
    var userID:String?
    var otherID:String?
	var otherName:String?
	var otherImageURL:String?
	
    let ipStr = ShareData.shared.IP
    
    var messageArray = ["messageArrayTest1", "messageArrayTest2", "messageArrayTest3"]
    var messageSenderFlag = [true, false, false]
    
    var messageList: [MockMessage] = []
    
    var cullentReadDict: [String: Int] = UserDefaults.standard.dictionary(forKey: "currentReadDict") as? [String: Int] ?? [:]
    var messageCount = 0
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var timer: Timer?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        print("前のビューコントローラーから来た値")
        guard let userIDStr = self.userID else{return}
        guard let userID = Int(userIDStr) else{return}
        
        guard let otherIDStr = self.otherID else{return}
        guard let otherID = Int(otherIDStr) else{return}
        print(userID)
        print(otherID)
        
		self.checkMessage(senderID: otherID, receiverID: userID)
		
        readMessage(myID: userID, otherID: otherID)
        // 1秒ごとにメッセージを引っ張ってくる
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.readMessage(myID: Int(self.userID!)!, otherID: Int(self.otherID!)!)
        }
        
        messagesCollectionView.backgroundColor = UIColor(red: 0xF1/255, green: 0xF5/255, blue: 0xF9/255, alpha: 1.0)

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar.delegate = self
        messageInputBar.sendButton.isEnabled = true
        messageInputBar.sendButton.tintColor = .systemBlue

        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let userIDStr = self.userID else{print("return1")
            return}
        guard let userID = Int(userIDStr) else{print("return2")
            return}
        
        guard let otherIDStr = self.otherID else{print("return3")
            return}
        guard let otherID = Int(otherIDStr) else{print("return4")
            return}
        
        if cullentReadDict[otherIDStr] != nil
        {
            cullentReadDict[otherIDStr] = self.messageCount
            print(cullentReadDict)
            
            
        }else{
            cullentReadDict[otherIDStr] = self.messageCount
            print("idに値が存在しなかった")
        }
        var cullentReadDict = [["userID": 1, "otherID":3, "readedID":5], ["userID": 1, "otherID":5, "readedID":5]]
        for i in 0..<cullentReadDict.count
        {
//            if cullentReadDict[i][otherIDStr] == otherID{}
//            guard let Dict = cullentReadDict[1] else{return}
//            print(cullentReadDict[1]["otherID"]!)
            if let value = cullentReadDict[i]["otherID"]
            {
                print(value)
                if value == otherID
                {
                    cullentReadDict[i]["readedID"] = self.messageCount
                    print("messageCountで上書きしました")
                }
            }else{print("valueがnilです")}
        }
        print("最新版の既読判定用辞書")
        print(cullentReadDict)
        
        UserDefaults.standard.set(cullentReadDict, forKey: "currentReadDict")
        
        timer?.invalidate()
        
//        print("画面が消える直前")
//        saveData()
    }
	
	func checkMessage(senderID:Int, receiverID:Int)
	{
		AF.request("\(self.ipStr)checkMessage.php",
				   method: .get,
				   parameters: ["senderID": senderID, "receiveID": receiverID],
				   encoding: URLEncoding.default)
		.response
		{ response in
		}
	}

    // メッセージを追加
    func addTextMessage(sendMessage: String, senderFlag: Bool) {
        let sender = senderFlag ? currentSender() : otherSender()
        let attributedText = NSAttributedString(
            string: sendMessage,
            attributes: [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: senderFlag ? UIColor.white : UIColor(red: 33/255, green: 58/255, blue: 86/255, alpha: 1)
            ]
        )
        let message = MockMessage(attributedText: attributedText, sender: sender as! Sender, messageId: UUID().uuidString, date: Date())
        messageList.append(message)
    }

    // サンプルメッセージ
    func getMessages() -> [MockMessage] {
        return [
            createOtherMessage(text: "あ"),
            createOtherMessage(text: "い"),
            createMyMessage(text: "き"),
            createMyMessage(text: "く"),
            createOtherMessage(text: "け")
        ]
    }
    
    // 相手から来たメッセージを作る関数
    func createOtherMessage(text: String) -> MockMessage
    {
        let attributedText = NSAttributedString(string: text,
                                                attributes: [.font: UIFont.systemFont(ofSize: 15),
                                                             .foregroundColor: UIColor.black])
        return MockMessage(attributedText: attributedText, sender: otherSender(), messageId: UUID().uuidString, date: Date())
    }
    
    // 自分が送ったメッセージを作る関数
    func createMyMessage(text: String) -> MockMessage
    {
        let attributedText = NSAttributedString(string: text,
                                                attributes: [.font: UIFont.systemFont(ofSize: 15),
                                                             .foregroundColor: UIColor(red: 33/255, green: 58/255, blue: 86/255, alpha: 1)])
        return MockMessage(attributedText: attributedText, sender: currentSender() as! Sender, messageId: UUID().uuidString, date: Date())
    }
    
    // メッセージ一覧をサーバーから取得
    func readMessage(myID: Int,otherID: Int)
    {
        self.messageList.removeAll()
        print(myID)
        print(otherID)
        AF.request("\(self.ipStr)messageList.php",
                   method: .post,
                   parameters: ["userID": myID, "otherID": otherID],
                   encoding: URLEncoding.default,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
        .response
        { response in
            let jsonText = JSON(response.data)
            print("メッセージ一覧レスポンス取得")
            print(jsonText)
            
//            for i
            self.messageArray = []
            self.messageSenderFlag = []
            self.messageCount = jsonText.count
            for i in 0..<jsonText.count
            {
                self.addTextMessage(sendMessage: jsonText[i]["messageValue"].stringValue, senderFlag: jsonText[i]["senderFlag"].boolValue)
                print(jsonText[i]["messageValue"])
            }
            
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom()
//            print(jsonText[0]["messageValue"])
        }
    }
    
    func sendMessage(senderID: Int, receiverID: Int, messageVal: String)
    {
        if messageVal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        {
            let alert = UIAlertController(title: "エラー", message: "メッセージを入力してください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        
        AF.request("\(self.ipStr)saveMessage.php",
                   method: .post,
                   parameters: ["senderID": senderID, "receiverID": receiverID, "messageVal": messageVal],
                   encoding: URLEncoding.default,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
        .response
        { response in
            print(response)
        }
    }
    
}

// MARK: - MessagesDataSource
extension ShinMessageViewController: MessagesDataSource {
    func currentSender() -> any MessageKit.SenderType { Sender(id: "123", displayName: "自分") }
	func otherSender() -> Sender { Sender(id: "456", displayName: self.otherName!) }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int { messageList.count }
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        guard indexPath.section < messageList.count else {
                return messageList.last!
            }

            return messageList[indexPath.section]
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [.font: UIFont.boldSystemFont(ofSize: 10),
                             .foregroundColor: UIColor.darkGray]
            )
        }
        return nil
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        NSAttributedString(string: message.sender.displayName, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        NSAttributedString(string: formatter.string(from: message.sentDate),
                           attributes: [.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

// MARK: - MessagesDisplayDelegate
extension ShinMessageViewController: MessagesDisplayDelegate {
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .white : .black
    }

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ?
        UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) :
        UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if isFromCurrentSender(message: message)
        {
            avatarView.isHidden = true
        }
        else
        {
            avatarView.isHidden = false
            if let imageName = self.otherImageURL
            {
                avatarView.sd_setImage(with: URL(string: "\(self.ipStr)uploads/\(imageName)"))
            }
            else
            {
                let avatar = Avatar(initials: "人")
                avatarView.set(avatar: avatar)
            }
        }
    }
}

// MARK: - MessagesLayoutDelegate
extension ShinMessageViewController: MessagesLayoutDelegate {
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        indexPath.section % 3 == 0 ? 10 : 0
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        16
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        16
    }

    func messageLabelInsets(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        isFromCurrentSender(message: message) ?
        UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12) :
        UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    }
}

// MARK: - MessageCellDelegate
extension ShinMessageViewController: MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) { print("Message tapped") }
}

// MARK: - InputBarAccessoryViewDelegate
//extension ShinMessageViewController: InputBarAccessoryViewDelegate {
//    func messageInputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//        print("aaa")
//        let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15),
//                                                                           .foregroundColor: UIColor.white])
//        let message = MockMessage(attributedText: attributedText, sender: currentSender() as! Sender, messageId: UUID().uuidString, date: Date())
//        messageList.append(message)
//        messagesCollectionView.insertSections([messageList.count - 1])
//        inputBar.inputTextView.text = ""
//        messagesCollectionView.scrollToBottom()
//    }
//}
extension ShinMessageViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        print("Sendボタン押された！")
        guard let senderID = self.userID else {return}
        guard let receiverID = self.otherID else {return}
        guard let messageVal = inputBar.inputTextView.text else {return}
        self.sendMessage(senderID: Int(senderID)!, receiverID: Int(receiverID)!, messageVal: messageVal)
        inputBar.inputTextView.text = ""
        inputBar.inputTextView.resignFirstResponder()
    }
}
