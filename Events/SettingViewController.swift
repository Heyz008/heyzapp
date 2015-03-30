//
//  SettingViewController.swift
//  Heyz
//
//  Created by Zhichao Yang on 2015-03-29.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

import UIKit
let section1 = ["Edit Profile", "My Account", "Find Friends"]
let section2 = ["Notifications", "Privacy", "Liked Account", "Language"]
let section3 = ["Like Us on Facebook", "Like Us on Twitter"]
let section4 = ["Rate Us", "Term of Use", "Privacy policy"]
let section5 = ["Clear Cache"]
let section6 = ["logout"]

let sections = [section1, section2, section3, section4, section5, section6]

class SettingViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return sections[section].count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let label = sections[indexPath.section][indexPath.row]
        var cell : UITableViewCell
        switch label{
            case "My Account":
                cell = tableView.dequeueReusableCellWithIdentifier("AccountCell", forIndexPath: indexPath) as AccountCell
                (cell as AccountCell).emailIndicator.font = UIFont.fontAwesomeOfSize(20)
                (cell as AccountCell).emailIndicator.text = String.fontAwesomeIconWithName(FontAwesome.InfoCircle)

                    cell.textLabel?.text = label
            case "Like Us on Facebook", "Like Us on Twitter":
                cell = tableView.dequeueReusableCellWithIdentifier("LikeCell", forIndexPath: indexPath) as UITableViewCell
                    cell.textLabel?.text = label
            case "Clear Cache":
                cell = tableView.dequeueReusableCellWithIdentifier("CacheCell", forIndexPath: indexPath) as UITableViewCell
                    cell.textLabel?.text = label
            case "logout":
                cell = tableView.dequeueReusableCellWithIdentifier("LogoutCell", forIndexPath: indexPath) as UITableViewCell
            default:
                cell = tableView.dequeueReusableCellWithIdentifier("NormalCell", forIndexPath: indexPath) as UITableViewCell
                    cell.textLabel?.text = label
        }
        cell.textLabel?.layer.zPosition = -1
        // Configure the cell...
        return cell
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

class NormalCell : UITableViewCell {
    
}

class CacheCell : UITableViewCell {
    
}

class AccountCell : UITableViewCell{
    @IBOutlet weak var emailIndicator: UILabel!
    
}

class LogoutCell : UITableViewCell {
    
}

class LikeCell : UITableViewCell{
    
}
