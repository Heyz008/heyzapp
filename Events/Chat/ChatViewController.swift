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

    @IBOutlet var viewForTitle : UIView!
    @IBOutlet var ctrlForChat : UISegmentedControl!
    @IBOutlet var btnForLogo : UIButton!
    @IBOutlet var itemForSearch : UIBarButtonItem!
    @IBOutlet var tblForChat : UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    let firebaseURL = "https://heyz.firebaseio.com"
    var user: FAuthData?
    var ref: Firebase!
    
    var fetchedResultController: NSFetchedResultsController!
    var messages: [String : NSMutableArray] = [:]
    
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
        
        self.navigationItem.titleView = viewForTitle
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btnForLogo)
        self.navigationItem.rightBarButtonItem = itemForSearch
        self.tabBarController?.tabBar.tintColor = UIColor.greenColor()
        // self.performSegueWithIdentifier("loginSegue", sender: nil)
        
        // TODO: make this for the overall app
        ref = Firebase(url: firebaseURL)
        
        ref.observeAuthEventWithBlock({ authData in
            if authData != nil {
                self.user = authData
                
                //Core Data
                var fetchRequest = NSFetchRequest(entityName: "Message")
                let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
                fetchRequest.sortDescriptors = [sortDescriptor]
                
                if let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext{
                    self.fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                    self.fetchedResultController.delegate = self
                    
                    var e: NSError?
                    var result = self.fetchedResultController.performFetch(&e)
                    let temp = self.fetchedResultController.fetchedObjects as [Message]
                    
                    //FIXME
                    let newMessageArr = NSMutableArray()
                    self.messages["simplelogin:3"] = newMessageArr
                    
                    for message in temp{
//                        if let messageArr = self.messages[message.getReceiver()]{
                            if message.getSender() == self.user?.uid {
                                newMessageArr.addObject(["message": message, "type": "2"])
                            } else {
                                newMessageArr.addObject(["message": message, "type": "1"])
                            }
//                        } else {
//                            let newMessageArr = NSMutableArray()
//                            self.messages[message.getReceiver()] = newMessageArr
//                            if message.getSender() == self.user?.uid {
//                                newMessageArr.addObject(["message": message, "type": "2"])
//                            } else {
//                                newMessageArr.addObject(["message": message, "type": "1"])
//                            }
//                            
//                        }
                    }
                    if result != true {
                        println("error fetching objects: \(e!.localizedDescription)")
                    }
                    
                }

            } else {
                self.performSegueWithIdentifier("loginSegue", sender: self)
            }
        })
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToChat (segueSelected : UIStoryboardSegue) {
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex{
        case 0:
            return 0
        default:
            return messages.count > 0 ? messages.count : 1
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        switch segmentedControl.selectedSegmentIndex{
        case 0:
            return tblForChat.dequeueReusableCellWithIdentifier("ChatPublicCell") as UITableViewCell
        default:
            return tblForChat.dequeueReusableCellWithIdentifier("ChatPrivateCell") as UITableViewCell
            
        }
        
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!){
        self.performSegueWithIdentifier("slideToChat", sender: nil);
    }

    @IBAction func indexChanged(sender: UISegmentedControl) {
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "slideToChat"{
            var messageVC = segue.destinationViewController as ChatDetailViewController
            if let authData = user as FAuthData!{
                messageVC.sender = authData
                messageVC.ref = ref
                
                //FIXME: may not need this
                if let messageArr =  messages["simplelogin:3"]{
                    messageVC.messages = messageArr
                } else {
                    messages["simplelogin:3"] = NSMutableArray()
                    messageVC.messages = messages["simplelogin:3"]
                }
                
            }
        }
        
    }
    
    //On after receiving a new message from firebase
//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        tblForChat.beginUpdates()
//    }
//    
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        tableView.reloadData()
//    }
    
    
    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
