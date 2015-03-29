//
//  ProfileViewController.swift
//  Heyz
//
//  Created by Zhichao Yang on 2015-03-14.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate{
    let tempViewController = UIViewController()
    var publishedEvent : ProgramViewController? {
        
        return self.navigationController?.storyboard?.instantiateViewControllerWithIdentifier("ProgramViewController") as? ProgramViewController
    }
    var eventFeed : UIViewController?{
        return self.navigationController?.storyboard?.instantiateViewControllerWithIdentifier("EventFeed") as? UIViewController
    }
    var pageViewController : UIPageViewController? {
        if let vc = self.childViewControllers.last as? UIPageViewController{
            return vc
        }
        else{
            NSException(name: "Cannot Find PageViewController", reason: "pageVC is not the last vc", userInfo: nil)
            return nil
        }
    }
    var isCurrentUser: Bool{
        return cyUser.isCurrentUser()
    }
    var user: PFUser{
        get{
            return cyUser.user
        }
    }
    private var _cyUser: CYUser?
    var cyUser : CYUser{
        set{
            self.userDidSet()
        }
        get{
            if let user = _cyUser{
                return user
            }else{
                return CYUserSelf.currentCYUser()
            }
        }
    }
    @IBOutlet weak var pageViewBar: UIView!
    @IBOutlet weak var goingEvents: UIButton! //参加的活动
    var goingEventsController : ProgramViewController?
    @IBOutlet weak var holdingEvents: UIButton! //举办的活动
    var holdingEventsController : ProgramViewController?
    @IBOutlet weak var likedEvets: UIButton!  //感兴趣的活动
    var likedEventsController : ProgramViewController?
    @IBOutlet weak var photos: UIButton!  //照片
    var photosController : UIViewController?


//MARK: Basic info views
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var profileImage: RoundImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var signLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var favorateButton: UIButton!
    var _moreButton : UIBarButtonItem?
    var moreButton : UIBarButtonItem!{
        if _moreButton == nil{
            _moreButton = UIBarButtonItem(title: String.fontAwesomeIconWithName(FontAwesome.EllipsisH), style: .Plain, target: self, action: "moreMenu")
            return _moreButton!
        }else{
            return _moreButton!
        }
    }
    @IBOutlet weak var setting: UIBarButtonItem!



    func moreMenu(){
        //TODO: pop up menu
    }
//MARK: - viewLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageViewController?.delegate = self
        self.pageViewController?.dataSource = self
        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        setting.setTitleTextAttributes(attributes, forState: .Normal)
        setting.title = String.fontAwesomeIconWithName(FontAwesome.Cog)
        moreButton.setTitleTextAttributes(attributes, forState: .Normal)
        self.userDidSet()

        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()        // Dispose of any resources that can be recreated.
    }
    
    func userDidSet(){
        self.setControllers()//获取collectionViewControllers
        self.arrageBasicInfoViews()
        
        let controllerData = self.getControllerData()//建立controller和button的联系
        controllerList = controllerData.1//排序好的controller 列表
        controllerDict = controllerData.0//controller：button字典
        self.controllerListLen = self.controllerList?.count
        if controllerListLen == 0{
            print("no view controller loaded!")
            self.pageViewController?.view.hidden = true
            return
        }
        if let pvc = self.pageViewController {
            pvc.setViewControllers([self.controllerList![0] as UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)//设定第一个page
            self.buttonForViewController(self.controllerList![0])?.tintColor = UIColor.redColor()//设定此page的button被选中
            self.arrangeControllerButtons()//均匀分配button
        }
        self.setUpBasicInfo()

    }

// MARK: PrepareViewControllers
    func setControllers(){
        if isCurrentUser{
            self.likedEventsController = self.navigationController?.storyboard?.instantiateViewControllerWithIdentifier("ProgramViewController") as? ProgramViewController
        }
        self.holdingEventsController = self.navigationController?.storyboard?.instantiateViewControllerWithIdentifier("ProgramViewController") as? ProgramViewController
        self.goingEventsController = self.navigationController?.storyboard?.instantiateViewControllerWithIdentifier("ProgramViewController") as? ProgramViewController
        self.photosController = self.navigationController?.storyboard?.instantiateViewControllerWithIdentifier("Gallery") as? GalleryCollectionViewController
    }
    var controllerDict : [UIViewController: UIButton]?
    var controllerList : [UIViewController]?
    var controllerListLen : Int?
    var onGoingViewcontroller = 0
    func getControllerData() ->([UIViewController: UIButton], [UIViewController]){
        var controllerList = [UIViewController]()
        var dict = [UIViewController: UIButton]()
        if let gVC = goingEventsController{
            dict[gVC] = goingEvents
            controllerList.append(gVC)
        }else{
            goingEvents.hidden = true
        }
        if let hVC = holdingEventsController{
            dict[hVC] = holdingEvents
            controllerList.append(hVC)
        }else{
            holdingEvents.hidden = true
        }
        if let lVC = likedEventsController{
            dict[lVC] = likedEvets
            controllerList.append(lVC)
        }else{
            likedEvets.hidden = true
        }
        if let pVC = photosController{
            dict[pVC] = photos
            controllerList.append(pVC)
        }else{
            photos.hidden = true
        }
        return (dict, controllerList)
    }
// MARK: PageViewController
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        println("moving left")
        if onGoingViewcontroller - 1 < 0{
            return nil
        }else{
            return controllerList![onGoingViewcontroller - 1]
        }
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        println("moving right")
        if onGoingViewcontroller + 1 == controllerListLen{
            return nil
        }else{
            return controllerList![onGoingViewcontroller + 1]
        }
    }
    var destinationVC : UIViewController?
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [AnyObject]) {
        self.destinationVC = pendingViewControllers[0] as? UIViewController
        return
    }
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        if completed && finished{
            buttonForViewController(destinationVC)?.tintColor = UIColor.redColor()
            buttonForViewController(previousViewControllers[0] as? UIViewController)?.tintColor = UIColor.blackColor()
            onGoingViewcontroller = getNumberForViewController(destinationVC)!
            println("transition completed and finished")

        }

    }
    
    func buttonForViewController( viewController : UIViewController? )-> UIButton?{
        if let dict = controllerDict{
            if let VC = viewController{
                return dict[VC]
            }
        }
        return nil
    }
    
    func getNumberForViewController( viewController: UIViewController?)-> Int?{
        if let len = self.controllerListLen{
            for var i = 0; i < len; ++i{
                if self.controllerList![i] == viewController{return i;}
                }
        }
        return nil
    }

// MARK: Handle Button Click
    private func movetToViewController(targetViewController : UIViewController?){
        
        let pageNum = getNumberForViewController(targetViewController)
        if let truePageNum = pageNum{
            if onGoingViewcontroller < truePageNum{
                destinationVC = targetViewController
                self.pageViewController?.setViewControllers([targetViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
                pageViewController(self.pageViewController!, didFinishAnimating: true, previousViewControllers: [controllerList![onGoingViewcontroller]], transitionCompleted: true)
            }else if onGoingViewcontroller > truePageNum{
                destinationVC = targetViewController
                self.pageViewController?.setViewControllers([targetViewController!], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: nil)
                pageViewController(self.pageViewController!, didFinishAnimating: true, previousViewControllers: [controllerList![onGoingViewcontroller]], transitionCompleted: true)
            }
        }

    }
    
    @IBAction func switchGoing(sender: AnyObject) {
        movetToViewController(goingEventsController)
    }
    @IBAction func switchHoldin(sender: AnyObject) {
        movetToViewController(holdingEventsController)
    }
    @IBAction func switchLiked(sender: AnyObject) {
        movetToViewController(likedEventsController)
    }
    @IBAction func switchPhotos(sender: AnyObject) {
        movetToViewController(photosController)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
// MARK: Arrage Views
    func arrangeControllerButtons(){
        if let lenth = controllerListLen{
            let interval = pageViewBar.frame.width / (CGFloat(lenth)*2 + 1)
            var i = 1
            for object in controllerList!{
                var button = controllerDict![object]
                button?.titleLabel?.textAlignment = NSTextAlignment.Center
                button?.tintColor = UIColor.blackColor()
                button!.frame = CGRect(origin: CGPoint(x: CGFloat(i) * interval, y: CGFloat(0)), size: button!.frame.size)
                i = i + 2
            }
        }else{
            return
        }
    }
    
    func arrageBasicInfoViews(){
        ageLabel.hidden = isCurrentUser
        statusLabel.hidden = isCurrentUser
        favorateButton.hidden = isCurrentUser
        if isCurrentUser{
            self.navigationItem.rightBarButtonItem = setting
        }else{
            self.navigationItem.rightBarButtonItem = moreButton
        }
    }
// MARK: set up some fake data
    func setUpBasicInfo(){
        self.statusLabel.text = "Single"
        self.profileImage.image = UIImage(named: "profile-pic2.c")
        self.nameLabel.text = "Daniel"
        self.locationLabel.text = "Toronto"
        self.sexLabel.font = UIFont.fontAwesomeOfSize(15)
        self.sexLabel.text = String.fontAwesomeIconWithName(FontAwesome.Male)
        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(15)] as Dictionary!
        self.signLabel.text = "PM"
        self.ageLabel.text = "?"
        self.favorateButton.titleLabel?.text = "F"
    }
}



class RoundImageView: UIImageView {
    
}
