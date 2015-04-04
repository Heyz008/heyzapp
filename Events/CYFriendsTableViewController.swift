//
//  FriendsTableViewController.swift
//  Heyz
//
//  Created by Zhichao Yang on 2015-03-21.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

import UIKit

class CYFriendsTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    var currentCYUser = CYUserSelf.currentCYUser()
    var idList : [String] = []{
        didSet{
            self.tableView.reloadData()
        }
    }

    @IBOutlet weak var friendSearchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        currentCYUser.getFriendListInBackground(onFinish: { (list) -> Void in
            self.idList = list
        })
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0{
            return 1
        }else if section == 1{
            return 2
        }else{
            return self.idList.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("defaultCell", forIndexPath: indexPath) as FriendCell

        if indexPath.section == 2{
            // Configure the cell...
            var userForLine = PFUser(withoutDataWithObjectId: idList[indexPath.row])
            userForLine.fetchIfNeededInBackgroundWithBlock { (user, error) -> Void in
                if error != nil{
                    println("friend fetch error.")
                }else{
                    cell.textLabel?.text = user.objectId
                }
            }
            
        }else{
            cell.imageView?.image = FakeUser.getFakeUser(indexPath.row).profileImage
            cell.textLabel?.text = FakeUser.getFakeUser(indexPath.row).info["name"]
        }
        if let width = cell.imageView?.frame.width{
            cell.imageView?.layer.cornerRadius = width / 2
            cell.imageView?.clipsToBounds = true;
        }

        return cell
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0: return "Favorate"
        case 1: return "All"
        case 2: return "Blocked"
        default: return ""
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let fakeUser = FakeUser.getFakeUser(indexPath.row)
        let profile = self.navigationController?.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as? ProfileViewController
        profile?.fakeUser = fakeUser
        if let controller = profile{
            self.navigationController?.pushViewController(controller, animated: true)

        }

    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let query = PFUser.query()
        query.whereKey("username", equalTo: searchBar.text)
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if error != nil{
                print(error)
            }else{
                if result.count  > 0{
                    let profileController = self.navigationController?.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as? ProfileViewController
                    if let vc = profileController{
                        vc.user = result.first as PFUser
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
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

class FriendCell: UITableViewCell {
    
}