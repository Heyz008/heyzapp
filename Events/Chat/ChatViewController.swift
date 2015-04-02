//
//  ChatViewController.swift
//  Chat
//
//  Created by My App Templates Team on 24/08/14.
//  Copyright (c) 2014 My App Templates. All rights reserved.
//

import UIKit
import CoreData

class ChatViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet var btnForLogo : UIButton!
    @IBOutlet var tblForChat : UITableView!
    
    let conversationManager = ConversationManager.singleton
    var _selectedConversation: Conversation?
    var startChatWith: String?
    
    var mDelegate: MessageDelegate?
    
    let delegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    let timer: NSTimer!
    let refreshRate = 6.0
    
    //收到离线或者未读消息
//    func onAfterMsgReceived(message: XMPPMessage) {
//        
//        
//        let from = "\(message.from().user)@\(message.from().domain)" as NSString
//        let body = message.elementForName("body").stringValue() as NSString
//        let delay = message.elementForName("delay") != nil
//        
//        let unread = Message(text: body, from: from, isDelay: delay, isSentByMe: false)
//        
//        conversationManager.addIncoming(unread, isPrivate: true)
//        
//        if mDelegate == nil {
//            tblForChat.reloadData()
//        } else {
//            mDelegate!.onAfterMsgReceived(message)
//        }
//        
//    }
    
    func fetchMessages(){
        
        conversationManager.updateGroupConversations(self)
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

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btnForLogo)
        self.tabBarController?.tabBar.tintColor = UIColor.greenColor()

        NSTimer.scheduledTimerWithTimeInterval(refreshRate, target: self, selector: "fetchMessages", userInfo: nil, repeats: true)
        
        let utils = AudioUtils.sharedUtils
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        conversationManager.loadGroupConversations(self)
        
        tblForChat.reloadData()
        mDelegate = nil
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToChat (segueSelected : UIStoryboardSegue) {
        
        if segueSelected.identifier == "unwindFromFriends" {

        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationManager.recentConversations.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        let conversation = conversationManager.getConversationAtIndex(indexPath.row)
        
        var cell: UITableViewCell
        if conversation.isPrivate {
            cell = tblForChat.dequeueReusableCellWithIdentifier("ChatPrivateCell") as UITableViewCell
            let unreadLabel = cell.viewWithTag(3)
            let timeLabel = cell.viewWithTag(4) as UILabel
            let senderLabel = cell.viewWithTag(6) as UILabel
            let messageLabel = cell.viewWithTag(8) as UILabel
            
            senderLabel.text = conversation.from
            
            if let lastMessage = (conversation.history.lastObject as? Message) {
                
                switch lastMessage.type {
                case "text":
                    messageLabel.text = (lastMessage.getContent() as String)
                case "voice":
                    messageLabel.text = "[Voice]"
                default:
                    messageLabel.text = "[Image]"
                }
                
                let timeArray = split(lastMessage.getTimestamp()) {$0 == "@"}
                timeLabel.text = timeArray.count > 1 ? timeArray[1] : ""
                
            } else {
                messageLabel.text = ""
                timeLabel.text = ""
            }
            
            if conversation.unread > 0 {
                unreadLabel!.hidden = false
            } else {
                unreadLabel!.hidden = true
            }
            
        } else {
            cell = tblForChat.dequeueReusableCellWithIdentifier("ChatPublicCell") as UITableViewCell
            let unreadLabel = cell.viewWithTag(8)
            let timeLabel = cell.viewWithTag(4) as UILabel
            let senderLabel = cell.viewWithTag(3) as UILabel
            let messageLabel = cell.viewWithTag(5) as UILabel
            let roundLabel = cell.viewWithTag(7) as UILabel
            let timeLeftLabel = cell.viewWithTag(6) as UILabel
            let backgroundView = cell.viewWithTag(2) as UIView!
            
            senderLabel.text = conversation.displayName
            
            if let lastMessage = (conversation.history.lastObject as? Message) {

                switch lastMessage.type {
                case "text":
                    messageLabel.text = (lastMessage.getContent() as String)
                case "voice":
                    messageLabel.text = "[Voice]"
                default:
                    messageLabel.text = "[Image]"
                }
                
                let timeArray = split(lastMessage.getTimestamp()) {$0 == "@"}
                timeLabel.text = timeArray.count > 1 ? timeArray[1] : ""
                
            } else {
                messageLabel.text = ""
                timeLabel.text = ""
            }
            
            if conversation.unread > 0 {
                unreadLabel!.hidden = false
            } else {
                unreadLabel!.hidden = true
            }
            
            roundLabel.text = "ROUND \(conversation.round)"
            
            if conversation.secs <= 60 {
                timeLeftLabel.text = "1 mins left"
            } else if conversation.secs <= 3600 {
                timeLeftLabel.text = "\(conversation.secs/60 + 1) mins left"
            } else {
                let hr = conversation.secs/3600
                let mins = (conversation.secs - 3600 * hr)/60
                timeLeftLabel.text = "\(hr) h \(mins) mins left"
            }
            
            let SEC_PER_ROUND: Int = conversationManager.SEC_PER_ROUND
            let width = Double((SEC_PER_ROUND - conversation.secs)) / Double(SEC_PER_ROUND)
            backgroundView.frame.size.width = CGFloat(Int(width * Double(cell.frame.size.width)))
            
        }
            
        return cell
        
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!){
        
        _selectedConversation = conversationManager.getConversationAtIndex(indexPath.row)
        if _selectedConversation!.isPrivate {
            self.performSegueWithIdentifier("slideToPChat", sender: self)
        } else {
            self.performSegueWithIdentifier("slideToGChat", sender: self)
        }
        
    }

    @IBAction func indexChanged(sender: UISegmentedControl) {
        tblForChat.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "slideToPChat" {
            var privateChatViewController = segue.destinationViewController as PrivateChatViewController
            privateChatViewController.conversation = _selectedConversation!
            _selectedConversation!.resetUnread()
            mDelegate = privateChatViewController
        } else if segue.identifier == "slideToGChat" {
            
            var groupChatViewController = segue.destinationViewController as GroupChatViewController
            groupChatViewController.conversation = _selectedConversation!
            _selectedConversation!.resetUnread()
            mDelegate = groupChatViewController
            
        } else if segue.identifier == "newChatSegue" {
            startChatWith = nil
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
