//
//  Custom media message.swift
//  Eazespot
//
//  Created by Kush Taneja on 21/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class ISCustomMediaMessageCell: JSQMediaItem {
 /*
    private var timeLabel:UILabel!
    private var textView:UITextView!
    private var statusIcon:UIImageView!
    private var warningButton:UIButton!
    private var size:CGSize!
    private var cachedMessageImageView:UIImageView?
    private var status:ISChatMessageStatus!
    
    //----------------------------------------------//
    init(text:String,date:NSDate,messageStatus:ISChatMessageStatus,outgoing:Bool) {
        //----------------------------------------------//
        textView = UITextView()
        timeLabel = UILabel()
        statusIcon = UIImageView()
        warningButton = UIButton()
        warningButton.hidden = true
        self.status = messageStatus
        
        super.init(maskAsOutgoing: outgoing)
        cachedMessageImageView = nil
        
        timeLabel.text = date.time
        textView.text = text
        timeLabel.text = date.time
        setTextView()
        prepareForCellLoad()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        timeLabel = nil
        textView = nil
        statusIcon = nil
        warningButton = nil
        size = nil
        status = nil
        self.cachedMessageImageView = nil
    }
    
    override func mediaView() -> UIView! {
        return cachedMessageImageView
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        return size!
    }
    
    private func prepareForCellLoad(){
        if self.appliesMediaViewMaskAsOutgoing{
            addStatusIcon()
            setStatusIcon()
            setFailedButton()
        }
        
        let colorBackGround:UIColor = self.appliesMediaViewMaskAsOutgoing ? UIColor(red: 0.57, green: 0.60, blue: 0.89, alpha: 1) : UIColor(red:0.92, green: 0.50, blue: 0.99, alpha: 1)
        let imgView:UIImageView = status == ISChatMessageStatus.Failed && self.appliesMediaViewMaskAsOutgoing ? UIImageView(frame: CGRectMake(-failDelta()/2, 0, size!.width, size!.height)) : UIImageView(frame: CGRectMake(0, 0, size!.width, size!.height))
        
        imgView.backgroundColor = colorBackGround
        imgView.clipsToBounds = true
        imgView.addSubview(textView)
        
        if self.appliesMediaViewMaskAsOutgoing{
            imgView.addSubview(statusIcon)
            imgView.addSubview(warningButton)
        }
        
        setTimeLabel()
        imgView.addSubview(timeLabel)
        imgView.autoresizingMask = textView.autoresizingMask
        JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMaskToMediaView(imgView, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
        imgView.userInteractionEnabled = true
        cachedMessageImageView = imgView
    }
    
    private func setTextView(){
        let max_Width = 0.7 * UIScreen.mainScreen().bounds.width
        textView.frame = CGRectMake(0, 0, max_Width, 0)
        textView.font = UIFont(name: "Helvetica", size: 17.0)
        textView.backgroundColor = UIColor.clearColor()
        textView.userInteractionEnabled = true
        textView.editable = false
        textView.scrollEnabled = false
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        textView.sizeToFit()
        
        
        let textView_Width = self.appliesMediaViewMaskAsOutgoing ? min(max_Width,max(textView.frame.size.width, 66)) : min(max_Width,max(textView.frame.size.width, 45))
        size =  self.appliesMediaViewMaskAsOutgoing ? CGSize(width: textView_Width + 30, height: textView.frame.size.height + 20) : CGSize(width: textView_Width + 30, height: textView.frame.size.height + 20)
        var autoResizing:UIViewAutoresizing?
        
        if self.appliesMediaViewMaskAsOutgoing{
            textView.frame = CGRectMake(10, 3, size!.width - 25, size!.height - 20)
            autoResizing = UIViewAutoresizing.FlexibleLeftMargin
        }else{
            textView.frame = CGRectMake(15,3, size!.width - 30, size!.height - 20)
            autoResizing = UIViewAutoresizing.FlexibleRightMargin
        }
        textView.autoresizingMask = autoResizing!
        
    }
    
    private func setStatusIcon(){
        switch status!{
        case .Sending:
            statusIcon.image = UIImage(named: "status_sending")!.jsq_imageMaskedWithColor(UIColor.whiteColor())
        case .Sent:
            statusIcon.image = UIImage(named: "status_sent")!.jsq_imageMaskedWithColor(UIColor.whiteColor())
        case .Received:
            statusIcon.image = UIImage(named: "status_notified")!.jsq_imageMaskedWithColor(UIColor.blueColor())
        case .Read:
            statusIcon.image = UIImage(named: "status_read")!.jsq_imageMaskedWithColor(UIColor.blueColor())
        case .Failed:
            statusIcon.image = UIImage(named: "status_sending")!.jsq_imageMaskedWithColor(UIColor.whiteColor())
        default :
            statusIcon.image = nil
        }
        if statusIcon.image != nil{
            statusIcon.image = statusIcon.image!.jsq_imageMaskedWithColor(UIColor.whiteColor())
        }
    }
    
    private func addStatusIcon(){
        statusIcon.frame = CGRectMake(15, isSingleLine() ? textView.frame.size.height - 5 : textView.frame.size.height, 15, 14)
        statusIcon.contentMode = .Left
        statusIcon.autoresizingMask = textView.autoresizingMask
        statusIcon.backgroundColor = UIColor.clearColor()
    }
    
    private func setTimeLabel(){
        timeLabel.frame = CGRectMake(0, 0, 31, 14)
        timeLabel.textColor = UIColor.whiteColor()
        timeLabel.font = UIFont(name: "Helvetica", size: 12.0)
        timeLabel.userInteractionEnabled = false
        timeLabel.alpha = 0.7
        timeLabel.textAlignment = .Left
        timeLabel.sizeToFit()
        
        var time_xPos:CGFloat
        let time_yPos:CGFloat = textView.frame.size.height//10 isSingleLine() ? textView.frame.size.height - 5 :
        
        if self.appliesMediaViewMaskAsOutgoing{
            time_xPos = statusIcon.frame.maxX + 3
        }else{
            time_xPos = textView.frame.maxX - timeLabel.frame.size.width - 5
        }
        
        timeLabel.frame = CGRectMake(time_xPos, time_yPos, timeLabel.frame.size.width, timeLabel.frame.size.height)
        timeLabel.autoresizingMask = textView.autoresizingMask
    }
    
    private func setFailedButton(){
        let b_size:CGFloat = 22
        let frame = CGRectMake(size!.width + b_size + self.failDelta()/2 + 5,(size!.height - b_size)/2 , b_size, b_size)
        warningButton.frame = frame
        warningButton.hidden = !self.isStatusFailedCase()
        warningButton.setImage(UIImage(named: "status_failed"), forState: .Normal)
    }
    
    private func isSingleLine() ->Bool {
        let textView_height = textView.frame.size.height
        let textView_width = textView.frame.size.width
        let view_width = size!.width
        return (textView_height <= 65 && textView_width <= 0.7 * view_width)
    }
    
    private func isStatusFailedCase() ->Bool {
        return status == ISChatMessageStatus.Failed
    }
    
    private func failDelta() ->CGFloat{
        return 60
    }
    
    func updateMessageStatus(status:ISChatMessageStatus){
        self.statusIcon.alpha = 0
        self.status = status
        self.setStatusIcon()
        UIView.animateWithDuration(0.5) { () -> Void in
            self.statusIcon.alpha = 1
        }
    }
    
    func getText() -> String{
        return self.textView.text!
    }
    
    func getStatus() -> String{
        return status.rawValue
    }*/
}
