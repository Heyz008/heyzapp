//
//  AboutViewController.h
//  Events
//
//  Created by Souvick Ghosh on 2/25/14.
//  Copyright (c) 2014 Teknowledge Software. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "EventList.h"
#import "LoginViewController.h"
#import "TSMiniWebBrowser.h"
#import <Parse/Parse.h>

#import "CustomPickerView.h"

@interface AboutViewController : ViewController<loginViewDelegate,UITextFieldDelegate,UITextViewDelegate,TSMiniWebBrowserDelegate,CustomPickerDelegate,UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    __weak IBOutlet UIView *vwFreeRegisterBtn;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewMain;
@property (strong, nonatomic) IBOutlet MKMapView *eventLocationMapView;
@property (strong, nonatomic) PFObject *eventObj;

@property (strong, nonatomic) NSMutableArray *arrayTotalSpaces;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSMutableArray *galleries;
@property (strong, nonatomic) IBOutlet UIImageView *eventImageView;
@property (strong, nonatomic) IBOutlet UILabel *eventName;
@property (strong, nonatomic) IBOutlet UILabel *eventOwner;
@property (strong, nonatomic) IBOutlet UILabel *eventTime;
@property (strong, nonatomic) IBOutlet UILabel *eventAddress;

@property (strong, nonatomic) IBOutlet UILabel *whoIsGoingLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *whoIsGoing;
@property (strong, nonatomic) IBOutlet UICollectionView *eventGallery;
@property (strong, nonatomic) IBOutlet UILabel *aboutLabel;
@property (strong, nonatomic) IBOutlet UILabel *aboutContent;
@property (strong, nonatomic) IBOutlet UILabel *commentLabel;
@property (strong, nonatomic) IBOutlet UITableView *comments;
@property (strong, nonatomic) IBOutlet UILabel *whoMoreLabel;
@property (strong, nonatomic) IBOutlet UIView *joinView;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *groupButton;
@property (strong, nonatomic) IBOutlet UIButton *mapDetailButton;
@property (strong, nonatomic) IBOutlet UIButton *joinButton;
@property (strong, nonatomic) IBOutlet UILabel *commentMoreLabel;

@property (strong, nonatomic) IBOutlet UIButton *addImageButton;
@property (strong, nonatomic) IBOutlet UIButton *qrButton;
@property (strong, nonatomic) IBOutlet UIImageView *qrImage;

@property (strong, nonatomic) NSMutableArray *commentUsers;
@property (strong, nonatomic) NSMutableArray *commentContents;

-(IBAction)addImageTapped:(id)sender;
-(IBAction)enterFullMap:(id)sender;
@end