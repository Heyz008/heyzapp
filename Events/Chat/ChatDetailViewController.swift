//
//  ChatDetailViewController.swift
//  Chat
//
//  Created by My App Templates Team on 26/08/14.
//  Copyright (c) 2014 My App Templates. All rights reserved.
//

import UIKit
import CoreData

class ChatDetailViewController: UIViewController, MessageDelegate {

    @IBOutlet var tblForChats : UITableView!
    @IBOutlet var chatComposeView : UIView!
    @IBOutlet var txtFldMessage : UITextField!
    
    var conversation: Conversation!
    
    let delegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    func onAfterMsgReceived(message: XMPPMessage) {
        
        let from = "\(message.from().user)@\(message.from().domain)"
        
        if from == conversation.from {
            
            conversation.resetUnread()
            
            tblForChats.reloadData()
            let indexPath = NSIndexPath(forRow:conversation.history.count - 1, inSection: 0)
            tblForChats.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
        
        
    }
    
    func addMessage(message: Message) {
        
        conversation.history.addObject(message)
        let indexPath = NSIndexPath(forRow:conversation.history.count - 1, inSection: 0)
        tblForChats.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
        tblForChats.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
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
        var text = message.getBody()
        var sizeOFStr = self.getSizeOfString(text)
        return sizeOFStr.height + 40
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell : UITableViewCell!
        var message: Message = conversation.history.objectAtIndex(indexPath.row) as Message
        var isSentByMe = message.isSentByMe
        var text = message.getBody()
        let timeArray = message.getTimestamp().componentsSeparatedByString("@ ")

        var sizeOFStr = self.getSizeOfString(text)
        
        if !isSentByMe {
            cell = tblForChats.dequeueReusableCellWithIdentifier("ChatSentCell") as UITableViewCell
            var textLabel = cell.viewWithTag(12) as UILabel
            var timeLabel = cell.viewWithTag(11) as UILabel
            var chatImage = cell.viewWithTag(1) as UIImageView
            var profileImage = cell.viewWithTag(2) as UIImageView
            chatImage.frame = CGRectMake(chatImage.frame.origin.x, chatImage.frame.origin.y, ((sizeOFStr.width + 50)  > 100 ? (sizeOFStr.width + 50) : 100), sizeOFStr.height + 30)
            chatImage.image = UIImage(named: "chat_new_receive")?.stretchableImageWithLeftCapWidth(30,topCapHeight: 20);
            textLabel.frame = CGRectMake(textLabel.frame.origin.x, textLabel.frame.origin.y, textLabel.frame.size.width, sizeOFStr.height)
            profileImage.center = CGPointMake(profileImage.center.x, textLabel.frame.origin.y + textLabel.frame.size.height - profileImage.frame.size.height/2 + 5)
            textLabel.text = text
            timeLabel.text = timeArray.count > 1 ? timeArray[1] : ""
        } else {
            cell = tblForChats.dequeueReusableCellWithIdentifier("ChatReceivedCell") as UITableViewCell
            // var deliveredLabel = cell.viewWithTag(13) as UILabel
            var textLabel = cell.viewWithTag(12) as UILabel
            var timeLabel = cell.viewWithTag(11) as UILabel
            var chatImage = cell.viewWithTag(1) as UIImageView
            var profileImage = cell.viewWithTag(2) as UIImageView
            var distanceFactor = (180.0 - sizeOFStr.width) < 140 ? (190.0 - sizeOFStr.width) : 140
            
            chatImage.frame = CGRectMake(30 + distanceFactor, chatImage.frame.origin.y, ((sizeOFStr.width + 50)  > 100 ? (sizeOFStr.width + 50) : 100), sizeOFStr.height + 30)
            chatImage.image = UIImage(named: "chat_new_send")?.stretchableImageWithLeftCapWidth(30,topCapHeight: 20);
            textLabel.frame = CGRectMake(41 + distanceFactor, textLabel.frame.origin.y, textLabel.frame.size.width, sizeOFStr.height)
            profileImage.center = CGPointMake(profileImage.center.x, textLabel.frame.origin.y + textLabel.frame.size.height - profileImage.frame.size.height/2 + 5)
            timeLabel.frame = CGRectMake(41 + distanceFactor, timeLabel.frame.origin.y, timeLabel.frame.size.width, timeLabel.frame.size.height)

            textLabel.text = text
            timeLabel.text = timeArray.count > 1 ? timeArray[1] : ""
        }
        return cell
    }
    
    func willShowKeyBoard(notification : NSNotification){
        
        var userInfo: NSDictionary!
        userInfo = notification.userInfo
        
        var duration : NSTimeInterval = 0
        var curve = userInfo.objectForKey(UIKeyboardAnimationCurveUserInfoKey) as UInt
        duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSTimeInterval
        var keyboardF:NSValue = userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey) as NSValue
        var keyboardFrame = keyboardF.CGRectValue()
        
        UIView.animateWithDuration(duration, delay: 0, options:nil, animations: {
            self.chatComposeView.frame = CGRectMake(self.chatComposeView.frame.origin.x, self.chatComposeView.frame.origin.y - keyboardFrame.size.height+self.chatComposeView.frame.size.height+3, self.chatComposeView.frame.size.width, self.chatComposeView.frame.size.height)
            
            self.tblForChats.frame = CGRectMake(self.tblForChats.frame.origin.x, self.tblForChats.frame.origin.y, self.tblForChats.frame.size.width, self.tblForChats.frame.size.height - keyboardFrame.size.height+49);
            }, completion: nil)
        
        if conversation.history.count > 0 {
            var indexPath = NSIndexPath(forRow:conversation.history.count - 1, inSection: 0)
            tblForChats.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
        
        
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
            self.chatComposeView.frame = CGRectMake(self.chatComposeView.frame.origin.x, self.chatComposeView.frame.origin.y + keyboardFrame.size.height-self.chatComposeView.frame.size.height-3, self.chatComposeView.frame.size.width, self.chatComposeView.frame.size.height)
            self.tblForChats.frame = CGRectMake(self.tblForChats.frame.origin.x, self.tblForChats.frame.origin.y, self.tblForChats.frame.size.width, self.tblForChats.frame.size.height + keyboardFrame.size.height-49);
            }, completion: nil)
        
    }
    
    func textFieldShouldReturn (textField: UITextField!) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func postBtnTapped() {
       
        let body = txtFldMessage.text
        let user = NSUserDefaults.standardUserDefaults().stringForKey(xmppDefaultIdKey)

        if !body.isEmpty {
            
            let message = Message(body: body, from: user!, isDelay: false, isSentByMe: true)
            txtFldMessage.text = ""
            
            self.addMessage(message)
            
            var xml = DDXMLElement.elementWithName("message") as DDXMLElement
            xml.addAttributeWithName("type", stringValue: "chat")
            xml.addAttributeWithName("to", stringValue: conversation.from)
            xml.addAttributeWithName("from", stringValue: user!)
            
            var bodyXML = DDXMLElement.elementWithName("body") as DDXMLElement
            bodyXML.setStringValue(body)
            
            xml.addChild(bodyXML)

            delegate.xmppStream.sendElement(xml)
            
        }

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
    
    
    
    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
