//
//  ChatViewController.swift
//  Chat
//
//  Created by My App Templates Team on 24/08/14.
//  Copyright (c) 2014 My App Templates. All rights reserved.
//

import UIKit
import CoreData

class ChatViewController: UIViewController, NSFetchedResultsControllerDelegate, MessageDelegate {

    @IBOutlet var btnForLogo : UIButton!
    @IBOutlet var tblForChat : UITableView!
    @IBOutlet weak var segCtrl: UISegmentedControl!
    
    let conversationManager = ConversationManager.singleton
    var _selectedConversation: Conversation?
    var startChatWith: String?
    
    var mDelegate: MessageDelegate?
    
    let delegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    //收到离线或者未读消息
    func onAfterMsgReceived(message: XMPPMessage) {
        
        
        let from = "\(message.from().user)@\(message.from().domain)" as NSString
        let body = message.elementForName("body").stringValue() as NSString
        let delay = message.elementForName("delay") != nil
        
        let unread = Message(text: body, from: from, isDelay: delay, isSentByMe: false)
        
        conversationManager.addIncoming(unread, isPrivate: true)
        
        if mDelegate == nil {
            tblForChat.reloadData()
        } else {
            mDelegate!.onAfterMsgReceived(message)
        }
        
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
        
        delegate.messageDelegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)

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
        switch segCtrl.selectedSegmentIndex{
        case 0:
            return conversationManager.recentConversations.count < 10 ? conversationManager.recentConversations.count : 10
        case 1:
            return conversationManager.publicConversations.count
        default:
            return conversationManager.privateConversations.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        let conversation = conversationManager.getConversationAtIndex(indexPath.row, type: segCtrl.selectedSegmentIndex)
        
        var cell: UITableViewCell
        if conversation.isPrivate {
            cell = tblForChat.dequeueReusableCellWithIdentifier("ChatPrivateCell") as UITableViewCell
            var unreadLabel = cell.viewWithTag(3)
            var timeLabel = cell.viewWithTag(4) as UILabel
            var senderLabel = cell.viewWithTag(6) as UILabel
            var messageLabel = cell.viewWithTag(8) as UILabel
            
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
                
            }
            
            if conversation.unread > 0 {
                unreadLabel!.hidden = false
            } else {
                unreadLabel!.hidden = true
            }
        } else {
            cell = tblForChat.dequeueReusableCellWithIdentifier("ChatPublicCell") as UITableViewCell
        }
            
        return cell
        
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!){
        
        _selectedConversation = conversationManager.getConversationAtIndex(indexPath.row, type: segCtrl.selectedSegmentIndex)
        self.performSegueWithIdentifier("slideToChat", sender: self);
    }

    @IBAction func indexChanged(sender: UISegmentedControl) {
        tblForChat.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "slideToChat"{
            var chatDetailViewController = segue.destinationViewController as ChatDetailViewController
            chatDetailViewController.conversation = _selectedConversation!
            _selectedConversation!.resetUnread()
            mDelegate = chatDetailViewController
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
