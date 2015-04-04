//
//  ChatDetailViewController.swift
//  Chat
//
//  Created by My App Templates Team on 26/08/14.
//  Copyright (c) 2014 My App Templates. All rights reserved.
//

import UIKit
import CoreData

class GroupChatViewController: UIViewController, MessageDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var tblForChats : UITableView!
    @IBOutlet var chatComposeView : UIView!
    @IBOutlet weak var chatCommandView: UIView!
    @IBOutlet var txtFldMessage : UITextField!
    @IBOutlet var viewForContent: UIView!
    @IBOutlet weak var scrollTopBtn: UIButton!
    
    let conversationManager: ConversationManager = ConversationManager.singleton
    var conversation: Conversation!
    
    let delegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    func onAfterMsgReceived(from: String) {

        if from == conversation.from {
            
            conversation.resetUnread()
            
            tblForChats.reloadData()
            let indexPath = NSIndexPath(forRow:conversation.history.count - 1, inSection: 0)
            tblForChats.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            
        }
        
        
    }
    
    func addMessage(message: Message) {
        
        conversation.add(message, isIncoming: false)
        conversationManager.topConversation(conversation)
        let indexPath = NSIndexPath(forRow:conversation.history.count - 1, inSection: 0)
        tblForChats.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
        tblForChats.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }
    
    @IBAction func handleVoiceLongPress(recognizer: UILongPressGestureRecognizer){
        if recognizer.state == .Began {
            
            AudioUtils.sharedUtils.startRecord(self)
            
        } else if recognizer.state == .Ended {
            
            AudioUtils.sharedUtils.stopRecord(self, onAfterSuccess: {(url: NSURL, duration: NSTimeInterval) -> Void in
                
                let data = NSData(contentsOfURL: url)
                let message = Message(voiceData: data!, voiceDuration: duration, isRead: true, from: "self", isDelay: false, isSentByMe: true)
                
                self.addMessage(message)
                self.conversationManager.sendGroupMessage(message, conversation: self.conversation)
                
                }, onAfterFailure: {() -> Void in
                    println("record failed")
            })

        }
    }
    
    @IBAction func onAfterVoiceTapped(sender: UIButton){
        
        let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tblForChats)
        if let indexPath = self.tblForChats.indexPathForRowAtPoint(buttonPosition){
            let message = conversation.history.objectAtIndex(indexPath.row) as Message
            
            if let data = message.voiceData {
                UIView.animateWithDuration(1.5, delay: 0.0, options: .Autoreverse | .Repeat, animations: {
                    sender.alpha = 0.3
                    }, completion: nil)
                AudioUtils.sharedUtils.playData(data, completion: {
                    sender.layer.removeAllAnimations()
                    sender.alpha = 1.0
                })
                
                if !message.isSentByMe {
                    if !(message.isRead!) {
                        message.isRead = true
                        self.tblForChats.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    }
                }
            }
            
            
        }
    }
    
    @IBAction func onAfterCameraTapped(sender: UIButton) {
    }
    
    @IBAction func onAfterPhotoTapped(sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .PhotoLibrary
            imagePicker.delegate = self
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as UIImage
        
//        let user = NSUserDefaults.standardUserDefaults().stringForKey(xmppDefaultIdKey)
        
        let message = Message(image: image, from: "self", isDelay: false, isSentByMe: true)
        
        self.addMessage(message)
        
        conversationManager.sendGroupMessage(message, conversation: conversation)
        
//        let xml = DDXMLElement.elementWithName("message") as DDXMLElement
//        xml.addAttributeWithName("type", stringValue: "chat")
//        xml.addAttributeWithName("to", stringValue: conversation.from)
//        xml.addAttributeWithName("from", stringValue: user!)
//        //        xml.addAttributeWithName("bodyType", stringValue: "photo")
//        
//        delegate.xmppStream.sendElement(xml)
        
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
        
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("willShowKeyBoard:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("willHideKeyBoard:"), name:UIKeyboardWillHideNotification, object: nil)
        
        let color = UIColor.grayColor().CGColor
        scrollTopBtn.layer.borderColor = color
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if conversation.history.count > 0 {
            let indexPath = NSIndexPath(forRow:conversation.history.count - 1, inSection: 0)
            tblForChats.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return conversation.history.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var message: Message = conversation.history.objectAtIndex(indexPath.row) as Message
        switch message.type {
        case "text":
            var text = message.getContent() as String
            var sizeOFStr = self.getSizeOfString(text)
            return sizeOFStr.height + 40
        case "voice":
            return CGFloat(52)
        default:
            return CGFloat(130)
        }
        
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        var cell : UITableViewCell!
        let message: Message = conversation.history.objectAtIndex(indexPath.row) as Message
        let isSentByMe = message.isSentByMe
        let timeArray = message.getTimestamp().componentsSeparatedByString("@ ")
        
        switch message.type {
        case "text":
            let text = message.getContent() as String
            let sizeOFStr = self.getSizeOfString(text)
            
            if isSentByMe {
                cell = tblForChats.dequeueReusableCellWithIdentifier("groupTextSentCell") as UITableViewCell
                // var deliveredLabel = cell.viewWithTag(13) as UILabel
                let textLabel = cell.viewWithTag(12) as UILabel
                let timeLabel = cell.viewWithTag(11) as UILabel
                let chatImage = cell.viewWithTag(1) as UIImageView
                let profileImage = cell.viewWithTag(2) as UIImageView
                let distanceFactor = (190.0 - sizeOFStr.width) < 140 ? (190.0 - sizeOFStr.width) : 140
                
                chatImage.frame = CGRectMake(30 + distanceFactor, chatImage.frame.origin.y, ((sizeOFStr.width + 50)  > 100 ? (sizeOFStr.width + 50) : 100), sizeOFStr.height + 30)
                chatImage.image = UIImage(named: "chat_new_send")?.stretchableImageWithLeftCapWidth(30,topCapHeight: 20)
                textLabel.frame = CGRectMake(40 + distanceFactor, textLabel.frame.origin.y, textLabel.frame.size.width, sizeOFStr.height)
                profileImage.center = CGPointMake(profileImage.center.x, textLabel.frame.origin.y + textLabel.frame.size.height - profileImage.frame.size.height/2 + 5)
                timeLabel.frame = CGRectMake(41 + distanceFactor, timeLabel.frame.origin.y, timeLabel.frame.size.width, timeLabel.frame.size.height)
                
                textLabel.text = text
                timeLabel.text = timeArray.count > 1 ? timeArray[1] : ""
            } else {
                cell = tblForChats.dequeueReusableCellWithIdentifier("groupTextReceivedCell") as UITableViewCell
                let textLabel = cell.viewWithTag(12) as UILabel
                let timeLabel = cell.viewWithTag(11) as UILabel
                let chatImage = cell.viewWithTag(1) as UIImageView
                let profileImage = cell.viewWithTag(2) as UIImageView
                chatImage.frame = CGRectMake(chatImage.frame.origin.x, chatImage.frame.origin.y, ((sizeOFStr.width + 50)  > 100 ? (sizeOFStr.width + 50) : 100), sizeOFStr.height + 30)
                chatImage.image = UIImage(named: "chat_new_receive")?.stretchableImageWithLeftCapWidth(30,topCapHeight: 20)
                textLabel.frame = CGRectMake(textLabel.frame.origin.x, textLabel.frame.origin.y, textLabel.frame.size.width, sizeOFStr.height)
                profileImage.center = CGPointMake(profileImage.center.x, textLabel.frame.origin.y + textLabel.frame.size.height - profileImage.frame.size.height/2 + 5)
                textLabel.text = text
                timeLabel.text = timeArray.count > 1 ? timeArray[1] : ""
            }
        case "voice":
            
            let voiceDuration = Int(message.voiceDuration!)
            let sizeOfVoice = self.getSizeOfVoice(message.voiceDuration!)
            
            if isSentByMe {
                cell = tblForChats.dequeueReusableCellWithIdentifier("groupVoiceSentCell") as UITableViewCell
                
                let distanceFactor = (240.0 - sizeOfVoice) < 190 ? (240.0 - sizeOfVoice) : 190
                
                let chatImage = cell.viewWithTag(1) as UIButton
                chatImage.frame = CGRectMake(30 + distanceFactor, chatImage.frame.origin.y, sizeOfVoice, chatImage.frame.size.height)
                chatImage.setBackgroundImage(UIImage(named: "chat_new_send")?.stretchableImageWithLeftCapWidth(30,topCapHeight: 20), forState: .Normal)
                
                let durationLabel = cell.viewWithTag(3) as UILabel
                durationLabel.frame = CGRectMake(40 + distanceFactor, durationLabel.frame.origin.y, durationLabel.frame.size.width, durationLabel.frame.size.height)
                durationLabel.text = "\(voiceDuration) ''"
            } else {
                cell = tblForChats.dequeueReusableCellWithIdentifier("groupVoiceReceivedCell") as UITableViewCell
                let unreadLabel = cell.viewWithTag(4)
                
                if message.isRead! {
                    unreadLabel!.hidden = true
                } else {
                    unreadLabel!.hidden = false
                }
                
                let chatImage = cell.viewWithTag(1) as UIButton
                chatImage.frame = CGRectMake(chatImage.frame.origin.x, chatImage.frame.origin.y, sizeOfVoice, chatImage.frame.size.height)
                chatImage.setBackgroundImage(UIImage(named: "chat_new_receive")?.stretchableImageWithLeftCapWidth(30,topCapHeight: 20), forState: .Normal)
//                chatImage.image =
                
                unreadLabel!.frame = CGRectMake(chatImage.frame.origin.x + sizeOfVoice + 5, unreadLabel!.frame.origin.y, unreadLabel!.frame.size.width, unreadLabel!.frame.size.height)
                
                let durationLabel = cell.viewWithTag(3) as UILabel
                durationLabel.frame = CGRectMake(chatImage.frame.origin.x + sizeOfVoice - 25, durationLabel.frame.origin.y, durationLabel.frame.size.width, durationLabel.frame.size.height)
                durationLabel.text = "\(voiceDuration) ''"
            }
            
            
        default:
            
            let image = (message.getContent() as UIImage)
            
            if isSentByMe {
                cell = tblForChats.dequeueReusableCellWithIdentifier("groupImageSentCell") as UITableViewCell
                let imageView = cell.viewWithTag(1) as UIImageView
                imageView.image = image
                imageView.contentMode = .ScaleAspectFill
                imageView.layer.cornerRadius = 5
                imageView.clipsToBounds = true
                
                let chatImage = cell.viewWithTag(3) as UIImageView
                chatImage.image = UIImage(named: "chat_new_send")?.stretchableImageWithLeftCapWidth(30,topCapHeight: 20)
            } else {
                cell = tblForChats.dequeueReusableCellWithIdentifier("groupImageReceivedCell") as UITableViewCell
                let imageView = cell.viewWithTag(1) as UIImageView
                imageView.image = image
                imageView.contentMode = .ScaleAspectFill
                imageView.layer.cornerRadius = 5
                imageView.clipsToBounds = true
                
                let chatImage = cell.viewWithTag(3) as UIImageView
                chatImage.image = UIImage(named: "chat_new_receive")?.stretchableImageWithLeftCapWidth(30,topCapHeight: 20)
            }
            
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!){
        
        txtFldMessage.resignFirstResponder()
        
    }
    
    func willShowKeyBoard(notification : NSNotification){

        var userInfo: NSDictionary!
        userInfo = notification.userInfo
        
        var duration: NSTimeInterval = 0
        var curve = userInfo.objectForKey(UIKeyboardAnimationCurveUserInfoKey) as UInt
        duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSTimeInterval
        var keyboardF:NSValue = userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey) as NSValue
        var keyboardFrame = keyboardF.CGRectValue()
        
        UIView.animateWithDuration(duration, delay: 0, options:nil, animations: {
            
            
            self.chatComposeView.frame = CGRectMake(self.chatComposeView.frame.origin.x, self.viewForContent.frame.size.height - keyboardFrame.size.height - self.chatComposeView.frame.size.height, self.chatComposeView.frame.size.width, self.chatComposeView.frame.size.height)
            self.chatCommandView.frame = CGRectMake(self.chatCommandView.frame.origin.x, self.viewForContent.frame.size.height - keyboardFrame.size.height, self.chatCommandView.frame.size.width, self.chatCommandView.frame.size.height)
            
            self.tblForChats.frame = CGRectMake(self.tblForChats.frame.origin.x, self.tblForChats.frame.origin.y, self.tblForChats.frame.size.width, self.viewForContent.frame.size.height - keyboardFrame.size.height - self.chatComposeView.frame.size.height + 1)
            
            if self.conversation.history.count > 0 {
                var indexPath = NSIndexPath(forRow: self.conversation.history.count - 1, inSection: 0)
                self.tblForChats.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
            }
        }, completion: nil)
        
        
        
    }
    
    func willHideKeyBoard(notification : NSNotification){

        var userInfo: NSDictionary!
        userInfo = notification.userInfo
        
        var duration : NSTimeInterval = 0
        var curve = userInfo.objectForKey(UIKeyboardAnimationCurveUserInfoKey) as UInt
        duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSTimeInterval
        var keyboardF:NSValue = userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey) as NSValue
        var keyboardFrame = keyboardF.CGRectValue()
        
        UIView.animateWithDuration(duration, delay: 0, options:nil, animations: {
            self.chatComposeView.frame = CGRectMake(self.chatComposeView.frame.origin.x, self.viewForContent.frame.size.height - self.chatCommandView.frame.size.height - self.chatComposeView.frame.size.height, self.chatComposeView.frame.size.width, self.chatComposeView.frame.size.height)
            self.chatCommandView.frame = CGRectMake(self.chatCommandView.frame.origin.x, self.viewForContent.frame.size.height - self.chatCommandView.frame.size.height, self.chatCommandView.frame.size.width, self.chatCommandView.frame.size.height)
            
            self.tblForChats.frame = CGRectMake(self.tblForChats.frame.origin.x, self.tblForChats.frame.origin.y, self.tblForChats.frame.size.width, self.viewForContent.frame.size.height - self.chatCommandView.frame.size.height - self.chatComposeView.frame.size.height + 1)
            }, completion: nil)
        
    }
    
    func textFieldShouldReturn (textField: UITextField!) -> Bool{
        
        let body = textField.text
//        let user = NSUserDefaults.standardUserDefaults().stringForKey(xmppDefaultIdKey)
        
        if !body.isEmpty {
            
            let message = Message(text: body, from: "self", isDelay: false, isSentByMe: true)
            textField.text = ""
            
            self.addMessage(message)
            
            conversationManager.sendGroupMessage(message, conversation: conversation)
            
//            var xml = DDXMLElement.elementWithName("message") as DDXMLElement
//            xml.addAttributeWithName("type", stringValue: "chat")
//            xml.addAttributeWithName("to", stringValue: conversation.from)
//            xml.addAttributeWithName("from", stringValue: user!)
//            
//            var bodyXML = DDXMLElement.elementWithName("body") as DDXMLElement
//            bodyXML.setStringValue(body)
//            
//            xml.addChild(bodyXML)
//            
//            delegate.xmppStream.sendElement(xml)
            
        }
        return true
    }
    
    func getSizeOfString(postTitle: NSString) -> CGSize {
        // Get the height of the font
        let constraintSize = CGSizeMake(170, CGFloat.max)
        
        let attributes = [NSFontAttributeName:UIFont.systemFontOfSize(11.0)]
        let labelSize = postTitle.boundingRectWithSize(constraintSize,
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: attributes,
            context: nil)

        return labelSize.size
    }
    
    func getSizeOfVoice(duration: NSTimeInterval) -> CGFloat {
        
        if duration <= 5 {
            return CGFloat(100)
        } else if duration >= 60 {
            return CGFloat(220)
        } else {
            return CGFloat(100 + 120 * duration / 55)
        }
    }
    
    
    
    /*
    // #pragma mark - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
