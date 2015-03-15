//
//  FriendsTableViewController.swift
//  Heyz
//
//  Created by Jay Yu on 2015-02-21.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

import UIKit

class FriendsTableViewController: UITableViewController {

    @IBOutlet var friendsTableView: UITableView!
    
    let userManager: UserManager = UserManager.singleton
    
    var requests = [String]()
    var friends = [String]()
    var selected: NSIndexPath?
    
    func onAfterRequestAction(fromUser: String, accepted: Bool){
        
        for i in 0 ..< requests.count {
            if requests[i] == fromUser {
                requests.removeAtIndex(i)
                break
            }
        }
        
        if accepted {
            friends.append(fromUser)
        }
        
        
        friendsTableView.reloadData()
    }
    
    @IBAction func sendFriendRequest(){
        
        let alertController = UIAlertController(title: "Send Friend Request", message: "Please enter email address below", preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler(nil)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        let resetAction = UIAlertAction(title: "Send", style: .Default, handler: { (action: UIAlertAction!) -> Void in
            if let textField = alertController.textFields!.first as? UITextField {
                self.userManager.sendFriendRequest(textField.text, sender: self)
            }
            
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(resetAction)
        
        presentViewController(alertController, animated: true, completion: nil)

    }
    
    func update(){
        
        userManager.updatePendingRequests(self)
        userManager.updateFriends(self)

    }
    
    func acceptFriendRequest(sender: AnyObject){
        let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
        if let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition){
            
            userManager.acceptFriendRequest(requests[indexPath.row], sender: self)
        }
    }
    
    func denyFriendRequest(sender: AnyObject){
        let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
        if let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition){
            userManager.denyFriendRequest(requests[indexPath.row], sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        update()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Your Pending Friend Request"
        } else {
            return "Your Friend List"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 1 {
            selected = indexPath
            self.performSegueWithIdentifier("unwindFromFriends", sender: self)
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return section == 0 ? requests.count : friends.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("requestCell") as UITableViewCell
            
            var textLabel = cell.viewWithTag(1) as UILabel
            textLabel.text = requests[indexPath.row]
            cell.selectionStyle = UITableViewCellSelectionStyle.None;
            
            var acceptBtn = cell.viewWithTag(2) as UIButton
            acceptBtn.addTarget(self, action: "acceptFriendRequest:", forControlEvents: .TouchUpInside)
            
            var denyBtn = cell.viewWithTag(3) as UIButton
            denyBtn.addTarget(self, action: "denyFriendRequest:", forControlEvents: .TouchUpInside)

        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("friendCell") as UITableViewCell
            
            var textLabel = cell.viewWithTag(1) as UILabel
            textLabel.text = friends[indexPath.row]

        }
        
        return cell
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindFromFriends"{
            if selected != nil {
                var chatViewController = segue.destinationViewController as ChatViewController
//                chatViewController.startChatWith = friendList[selected!.row]
            }
            
            
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
