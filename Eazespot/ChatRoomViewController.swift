//
//  ChatRoomViewController.swift
//  Eazespot
//
//  Created by Kush Taneja on 10/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit
import XMPPFramework
import JSQMessagesViewController
import SVPullToRefresh


class ChatRoomViewController: JSQMessagesViewController,EazeMessageDelegate,ContactPickerDelegate {
    
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var messages = NSMutableArray()
    var recipient: XMPPUserCoreDataStorageObject?
    var firstTime = true
    var userDetails : UIView?
    var initialCount: Int = 0
    
    
    
    
    // Mark: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialCount = messages.count
        EazeMessage.sharedInstance.delegate = self
        self.collectionView.addInfiniteScrolling( actionHandler: { () -> Void in
        self.loadMore() }, direction: UInt(SVInfiniteScrollingDirectionTop))
        
        self.collectionView.infiniteScrollingView.isHidden = false

        
        
        // Retrive History messages
        if EazeMessage.sharedInstance.messageCoreDataIsEmptyFor(jid:(recipient?.jidStr)!){
            
            XMPPMessageArchivingManagement().retriveChatHistoryFrom(fromBareJid:(recipient?.jidStr)!)
        }
        
        if EazeChat.sharedInstance.isConnected() {
            
            self.senderId = EazeChat.sharedInstance.xmppStream?.myJID.bare()
            self.senderDisplayName = EazeChat.sharedInstance.xmppStream?.myJID.bare()
            
        }
        
        self.collectionView!.collectionViewLayout.springinessEnabled = false
        self.inputToolbar!.contentView!.leftBarButtonItem!.isHidden = true
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let recipient = recipient {
            self.navigationItem.rightBarButtonItems = []
            navigationItem.title = recipient.displayName
            
            //MARK: Adding LastActivity functionality to NavigationBar
            
            EazeLastActivity.sendLastActivityQueryToJID(userName: (recipient.jidStr), sender: EazeChat.sharedInstance.xmppLastActivity) { (response, forJID, error) -> Void in
                
                let lastActivityResponse = EazeLastActivity.sharedInstance.getStringForNavigationBarFrom(seconds: (response?.lastActivitySeconds())!)
                debugPrint("last Seen \(lastActivityResponse)")
                
                let statusLabel = UILabel()
                self.navigationItem.title = lastActivityResponse
                statusLabel.text = lastActivityResponse
                self.navigationController?.view.addSubview(statusLabel)
                
                
                //   self.userDetails = EazeLastActivity.sharedInstance.addLastActivityLabelToNavigationBar(lastActivityResponse, displayName: recipient.displayName)
                //    self.navigationController!.view.addSubview(self.userDetails!)
                
                //   if (self.userDetails != nil) {
                //  self.navigationItem.title = ""
                //   }
            }
            DispatchQueue.main.async {
                self.messages = EazeMessage.sharedInstance.loadArchivedMessagesFrom(jid: recipient.jidStr)
                self.finishReceivingMessage(animated: true)
                if (self.messages.count >= 20) {
                    self.collectionView.addInfiniteScrolling( actionHandler: { () -> Void in
                        self.loadMore() }, direction: UInt(SVInfiniteScrollingDirectionTop))
                    self.collectionView.infiniteScrollingView.isHidden = false
                    
                }
            }
        } else {
            if userDetails == nil {
                navigationItem.title = "New message"
                
                
            }
            
            self.inputToolbar!.contentView!.rightBarButtonItem!.isEnabled = false
            /*
             self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: Selector("addRecipient")), animated: true)
             if firstTime {
             firstTime = false
             addRecipient()
             }
             
             */
        }
        
    }
    
    // Mark: Private methods
    /*
     func addRecipient() {
     let navController = self.storyboard?.instantiateViewController(withIdentifier: "contactListNav") as? UINavigationController
     let contactController: ContactListTableViewController? = navController?.viewControllers[0] as? ContactListTableViewController
     contactController?.delegate = self
     
     self.present(navController!, animated: true, completion: nil)
     }
     
     */
    func didSelectContact(recipient: XMPPUserCoreDataStorageObject) {
        self.recipient = recipient
        if userDetails == nil {
            navigationItem.title = recipient.displayName
        }
        
        if !EazeChats.knownUserForJid(jidStr: recipient.jidStr) {
            EazeChats.addUserToChatList(jidStr: recipient.jidStr)
        } else {
            messages = EazeMessage.sharedInstance.loadArchivedMessagesFrom(jid: recipient.jidStr)
            finishReceivingMessage(animated: true)
        }
    }
    
    
    // Mark: JSQMessagesViewController method overrides
    
    var isComposing = false
    var timer: Timer?
    
    override func textViewDidChange(_ textView: UITextView){
        super.textViewDidChange(textView)
        if textView.text.characters.count == 0 {
            if isComposing {
                hideTypingIndicator()
            }
        } else {
            timer?.invalidate()
            if !isComposing {
                isComposing = true
                EazeMessage.sendIsComposingMessage(recipient: (recipient?.jidStr)!, completionHandler: { (stream, message) -> Void in
                    self.timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ChatRoomViewController.hideTypingIndicator), userInfo: nil, repeats: false)
                })
            } else {
                timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ChatRoomViewController.hideTypingIndicator), userInfo: nil, repeats: false)
            }
        }
    }
    
    func hideTypingIndicator() {
        if let recipient = recipient {
            isComposing = false
            EazeMessage.sendIsComposingMessage(recipient: (recipient.jidStr)!, completionHandler: { (stream, message) -> Void in
                
            })
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!){
        
        let fullMessage = JSQMessage(senderId: EazeChat.sharedInstance.xmppStream?.myJID.bare(), senderDisplayName: EazeChat.sharedInstance.xmppStream?.myJID.bare(), date: Date(), text: text)
        messages.add(fullMessage!)
        if let recipient = recipient {
            EazeMessage.sendMessage(message: text, to: recipient.jidStr, completionHandler: { (stream, message) -> Void in
                
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage(animated: true)
            })
        }
    }
    
    // Mark: JSQMessages CollectionView DataSource
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        
        return message
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        let outgoingBubbleImageData = bubbleFactory?.outgoingMessagesBubbleImage(with: ColorCode().appThemeColor)
        let incomingBubbleImageData = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        
        
        if message.senderId == self.senderId {
            return outgoingBubbleImageData
        }
        
        return incomingBubbleImageData
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        
        if message.senderId == self.senderId {
            if let photoData = EazeChat.sharedInstance.xmppvCardAvatarModule?.photoData(for: EazeChat.sharedInstance.xmppStream?.myJID) {
                let senderAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: photoData), diameter: 30)
                return senderAvatar
            } else {
                let senderAvatar = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: "SR", backgroundColor: UIColor(white: 0.85, alpha: 1.0), textColor: UIColor(white: 0.60, alpha: 1.0), font: UIFont(name: "Helvetica Neue", size: 14.0), diameter: 30)
                return senderAvatar
            }
        } else {
            
            if let photoData = EazeChat.sharedInstance.xmppvCardAvatarModule?.photoData(for: recipient!.jid!) {
                let recipientAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: photoData), diameter: 30)
                return recipientAvatar
            } else {
                let recipientAvatar = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: "SR", backgroundColor: UIColor(white: 0.85, alpha: 1.0), textColor: UIColor(white: 0.60, alpha: 1.0), font: UIFont(name: "Helvetica Neue", size: 14.0)!, diameter: 30)
                return recipientAvatar
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        
        if message.senderId == self.senderId {
            return nil
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage: JSQMessage = self.messages[indexPath.item - 1] as! JSQMessage
            if previousMessage.senderId == message.senderId {
                return nil
            }
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return nil
    }
    
    // Mark: UICollectionView DataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell: JSQMessagesCollectionViewCell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let msg: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        
        if !msg.isMediaMessage {
            if msg.senderId == self.senderId {
                cell.textView!.textColor = UIColor.white
                cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName:UIColor.black, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
            } else {
                cell.textView!.textColor = UIColor.black
                cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName:UIColor.white, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
            }
        }
        
        return cell
    }
    
    // Mark: JSQMessages collection view flow layout delegate
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let currentMessage: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        if currentMessage.senderId == self.senderId {
            return 0.0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage: JSQMessage = self.messages[indexPath.item - 1] as! JSQMessage
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 0.0
    }
    
    
    // MARK: Chat message Delegates
    
    func EazeStream(sender: XMPPStream, didReceiveHistoryMessage historyMessage: XMPPMessage, from user: XMPPUserCoreDataStorageObject,on date: Date) {
        
       EazeMessage.sharedInstance.xmppMessageStorage?.archiveHistoryMessage(historyMessage, outgoing: false, xmppStream: EazeChat.sharedInstance.xmppStream, delay: date)
        
        DispatchQueue.main.async {
            self.messages = EazeMessage.sharedInstance.loadArchivedMessagesFrom(jid: (self.recipient?.jidStr)!)
            self.finishReceivingMessage(animated: true)
            if (self.messages.count >= 20) {
                self.collectionView.addInfiniteScrolling( actionHandler: { () -> Void in
                    self.loadMore() }, direction: UInt(SVInfiniteScrollingDirectionTop))
                self.collectionView.infiniteScrollingView.isHidden = false
                
            }
        }

        
        //EazeMessage.sharedInstance.xmppMessageStorage?.archiveMessage(historyMessage, outgoing: false, xmppStream: EazeChat.sharedInstance.xmppStream)
        /*
        if historyMessage.isChatMessageWithBody() {
            
             if (messages.count >= 20){
                
                let displayName = user.displayName
                if let msg: String = historyMessage.forName("body")?.stringValue {
                    if let from: String = historyMessage.attribute(forName: "from")?.stringValue {
                        let message = JSQMessage(senderId: from, senderDisplayName: displayName, date: date, text: msg)
                        DispatchQueue.main.async {
                        self.messages.insert(message!, at: self.messages.count-20)
                            self.finishReceivingMessage()
                            let indexpath = IndexPath(item: 0, section: 0)
                            //JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            self.scroll(to: indexpath, animated: true)

                        self.initialCount = self.messages.count
                 //       JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                       //     self.finishReceivingMessage(animated: true)
                        
                        }
                    }
                    
                }
                
            } else {
                let displayName = user.displayName
                if let msg: String = historyMessage.forName("body")?.stringValue {
                    if let from: String = historyMessage.attribute(forName: "from")?.stringValue {
                        let message = JSQMessage(senderId: from, senderDisplayName: displayName, date: date, text: msg)
                        DispatchQueue.main.async {
                        self.messages.add(message!)
                            self.finishReceivingMessage()
                            let indexpath = IndexPath(item: 0, section: 0)
                            //JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            self.scroll(to: indexpath, animated: true)
    
                        self.initialCount = self.messages.count
                     //   JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                            
                        }
                    }
                    
                }
                
            }
            
            if (messages.count >= 19){
                DispatchQueue.main.async {
                self.collectionView.addInfiniteScrolling( actionHandler: { () -> Void in
                    self.loadMore() }, direction: UInt(SVInfiniteScrollingDirectionTop))
                    self.collectionView.infiniteScrollingView.isHidden = false
                }
                
            }
            
            
        }*/
    }
    
    
    func EazeStream(sender: XMPPStream, didSendHistoryMessage historyMessage: XMPPMessage,on date: Date) {
        
        
        EazeMessage.sharedInstance.xmppMessageStorage?.archiveHistoryMessage(historyMessage, outgoing: true, xmppStream: EazeChat.sharedInstance.xmppStream, delay: date)
        
        DispatchQueue.main.async {
            self.messages = EazeMessage.sharedInstance.loadArchivedMessagesFrom(jid: (self.recipient?.jidStr)!)
            self.finishReceivingMessage(animated: true)
            if (self.messages.count >= 20) {
                self.collectionView.addInfiniteScrolling( actionHandler: { () -> Void in
                    self.loadMore() }, direction: UInt(SVInfiniteScrollingDirectionTop))
                self.collectionView.infiniteScrollingView.isHidden = false
                
            }
        }
        /*
        if historyMessage.isChatMessageWithBody() {
            
            if (messages.count >= 20) {
                
                if let text: String = historyMessage.forName("body")?.stringValue {
                    let fullMessage = JSQMessage(senderId: EazeChat.sharedInstance.xmppStream?.myJID.bare(), senderDisplayName: EazeChat.sharedInstance.xmppStream?.myJID.bare(), date: date, text: text)
                    DispatchQueue.main.async {
                    self.messages.insert(fullMessage!, at: self.messages.count-20)
                    self.initialCount = self.messages.count
                    self.finishSendingMessage()
                    let indexpath = IndexPath(item: 0, section: 0)
                    //JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.scroll(to: indexpath, animated: true)
                
                    }
                }
                
            }
            else {
                
                if let text: String = historyMessage.forName("body")?.stringValue {
                    let fullMessage = JSQMessage(senderId: EazeChat.sharedInstance.xmppStream?.myJID.bare(), senderDisplayName: EazeChat.sharedInstance.xmppStream?.myJID.bare(), date: date, text: text)
                     DispatchQueue.main.async {
                    self.messages.add(fullMessage!)
                    self.initialCount = self.messages.count
                    self.finishSendingMessage()
                    let indexpath = IndexPath(item: 0, section: 0)
                    //JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.scroll(to: indexpath, animated: true)
                    //JSQSystemSoundPlayer.jsq_playMessageSentSound()
                  
                    }
                    
                }
                
                
            }
            
        }
        
        
        if (messages.count >= 19) {
             DispatchQueue.main.async {
                          }
        }
        
        */
    }
    
    
    
    
    func EazeStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject) {
        if message.isChatMessageWithBody() {
            let displayName = user.displayName
            
            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
            
            if let msg: String = message.forName("body")?.stringValue {
                if let from: String = message.attribute(forName: "from")?.stringValue {
                    let message = JSQMessage(senderId: from, senderDisplayName: displayName, date: NSDate() as Date!, text: msg)
                    messages.add(message!)
                    
                    self.finishReceivingMessage(animated: true)
                }
            }
        }
    }
    
    func EazeStream(sender: XMPPStream, userIsComposing user: XMPPUserCoreDataStorageObject) {
        self.showTypingIndicator = !self.showTypingIndicator
        self.scrollToBottom(animated: true)
    }
    
    func loadMore() {
        
        debugPrint("Load earlier messages triggered by scroll! : \(messages[0])")
        
        initialCount = messages.count
        
        collectionView.collectionViewLayout.springinessEnabled = true
        self.collectionView.infiniteScrollingView.startAnimating()
        
        debugPrint("MMMM**\(messages.count)")
        
        XMPPMessageArchivingManagement().continueRetriveChatHistory(fromBareJid: (self.recipient?.jidStr)!)
        
        
      //  automaticallyScrollsToMostRecentMessage = true
        self.collectionView.infiniteScrollingView.stopAnimating()
        self.collectionView.collectionViewLayout.springinessEnabled = false
        self.collectionView.infiniteScrollingView.isHidden = true
        
        if ((messages.count - initialCount) >= 20) {
            
            self.collectionView.infiniteScrollingView.isHidden = false
            self.collectionView.addInfiniteScrolling( actionHandler: { () -> Void in
                self.loadMore() }, direction: UInt(SVInfiniteScrollingDirectionTop))
//  automaticallyScrollsToMostRecentMessage = true
            
        }
        
    }
    
    
    // Mark: Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

