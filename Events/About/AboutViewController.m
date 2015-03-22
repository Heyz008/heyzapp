//
//  AboutViewController.m
//  Events
//
//  Created by Souvick Ghosh on 2/25/14.
//  Copyright (c) 2014 Teknowledge Software. All rights reserved.
//

#import "AboutViewController.h"
#import "AboutCustomCell1.h"
#import "AboutCustomCell2.h"
#import "AboutCustomCell3.h"
#import "LocationManager.h"
#import "MyAnnotation.h"
#import "MyProgramViewController.h"
#import "FavouriteEvents.h"
#import "AppDelegate.h"
#import "NSString+FontAwesome.h"
#import "WhoIsGoingCollectionViewCell.h"
#import "WhoIsGoingViewController.h"
#import "DescriptionDetailViewController.h"
#import "CommentSummaryCell.h"
#import "ProgramDescriptionViewController.h"

@interface AboutViewController ()
{
    float descriptionTextHeight;
}

@end

@implementation AboutViewController
@synthesize scrollViewMain, eventLocationMapView;
@synthesize eventObj;
@synthesize arrayTotalSpaces;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self initializeNavigationBar];
    
    self.photos = [@[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg", @"5.jpg"] mutableCopy];
    
    self.commentUsers = [@[@"You", @"MoMo", @"LuLu"] mutableCopy];
    self.commentContents = [@[@"Very Good Event", @"I really want to go!!!", @"HeyHeyHey YoYoYo"] mutableCopy];
    self.comments.delegate = self;
    
    self.whoIsGoing.delegate = self;
    
    self.eventName.text = self.eventObj[@"title"];
    self.eventOwner.text = [NSString stringWithFormat:@"Hosted by Heyz . %@ . %@", self.eventObj[@"privacy"], self.eventObj[@"payment"]];
    self.eventTime.font = [UIFont fontWithName:kFontAwesomeFamilyName size:12];
    self.eventAddress.font = [UIFont fontWithName:kFontAwesomeFamilyName size:12];
    self.eventTime.text = [NSString stringWithFormat:@"%@  %@ - %@", [NSString fontAwesomeIconStringForIconIdentifier:@"fa-heart"], self.eventObj[@"from"], self.eventObj[@"to"]];
    self.eventAddress.text = [NSString stringWithFormat:@"%@  %@", [NSString fontAwesomeIconStringForIconIdentifier:@"fa-heart"], self.eventObj[@"address"]];
    PFFile *eventImageFile = self.eventObj[@"image"];
    [eventImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.eventImageView.image = [UIImage imageWithData:imageData];
        }
    }];
    
    self.aboutContent.text = self.eventObj[@"description"];
    
    
    self.whoMoreLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:12];
    self.whoMoreLabel.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-right"];
    
    self.aboutLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:12];
    self.aboutLabel.text = [NSString stringWithFormat:@"Learn More   %@", [NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-right"]];
    
    self.commentMoreLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:12];
    self.commentMoreLabel.text = [NSString stringWithFormat:@"View All   %@", [NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-right"]];
    
    UIColor *buttonColor = [UIColor colorWithRed:235.0/255 green:108.0/255 blue:118.0/255 alpha:1.0];
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-share-square-o"] style:UIBarButtonItemStylePlain target:self action:@selector(shareEvent)];
    [shareButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:kFontAwesomeFamilyName size:22], NSFontAttributeName,
                                         buttonColor, NSForegroundColorAttributeName,
                                         nil] forState:UIControlStateNormal];
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-ellipsis-h"] style:UIBarButtonItemStylePlain target:self action:@selector(eventAction)];
    [actionButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:kFontAwesomeFamilyName size:22], NSFontAttributeName,
                                         buttonColor, NSForegroundColorAttributeName,
                                         nil] forState:UIControlStateNormal];
    
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedItem.width = 18.0f;
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:shareButton, fixedItem, actionButton, nil]];
    
    
    
    descriptionTextHeight = [Utility getTextSize:[self.eventObj objectForKey:@"description"]textWidth:300 fontSize:14.0f lineBreakMode:NSLineBreakByWordWrapping].height;
    
    
    if (IS_IPHONE_5) {
        self.scrollViewMain.frame = CGRectMake(self.scrollViewMain.frame.origin.x, self.scrollViewMain.frame.origin.y, self.scrollViewMain.frame.size.width, self.scrollViewMain.frame.size.height+100);
    
        self.scrollViewMain.contentSize = CGSizeMake(self.scrollViewMain.frame.size.width, vwFreeRegisterBtn.frame.origin.y+vwFreeRegisterBtn.frame.size.height+50);
    }
    else{
        self.scrollViewMain.contentSize = CGSizeMake(self.scrollViewMain.frame.size.width, vwFreeRegisterBtn.frame.origin.y+vwFreeRegisterBtn.frame.size.height+50);
    }
    
    CGSize scrollSize = CGSizeMake(self.scrollViewMain.frame.size.width, self.comments.frame.origin.y + self.comments.frame.size.height);
    self.scrollViewMain.contentSize = scrollSize;
    
    self.likeButton.layer.cornerRadius = 6;
    self.joinButton.layer.cornerRadius = 6;
    self.groupButton.layer.cornerRadius = 6;
    CGRect joinFrame = self.joinView.frame;
    joinFrame.origin.y = self.scrollViewMain.frame.origin.y + self.scrollViewMain.frame.size.height;
    self.joinView.frame = joinFrame;
}

-(void)eventAction {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"ACTION" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Invite",
                            @"Report",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

//- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
//    
//    switch (popup.tag) {
//        case 1: {
//            switch (buttonIndex) {
//                case 0: {
//                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
//                        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//                        
//                        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
//                        picker.delegate = self;
//                        picker.allowsEditing=YES;
//                        picker.sourceType = sourceType;
//                        [self presentViewController:picker animated:YES completion:nil];
//                    }
//                }
//                case 1:{
//                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//                        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
//                        
//                        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
//                        picker.delegate = self;
//                        picker.allowsEditing=YES;
//                        picker.sourceType = sourceType;
//                        [self presentViewController:picker animated:YES completion:nil];
//                    }
//                }
//                default:
//                    break;
//            }
//            break;
//        }
//        default:
//            break;
//    }
//}



-(void)shareEvent {
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    [sharingItems addObject:self.eventName.text];
    [sharingItems addObject:self.eventImageView.image];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint];
    [self presentViewController:activityController animated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    self.tabBarController.tabBar.hidden=NO;
    /**
     *  get location using locationmanager singleton class
     */
    [LocationManager sharedInstance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initialize Navigation bar
-(void)initializeNavigationBar{
    self.title = self.eventObj[@"name"];
    UIImage* image1 = [UIImage imageNamed:@"share.png"];
    CGRect frameimg1 = CGRectMake(0, 0, image1.size.width, image1.size.height);
    UIButton *shareButton = [[UIButton alloc] initWithFrame:frameimg1];
    [shareButton setImage:image1 forState:UIControlStateNormal];
    [shareButton setImage:[UIImage imageNamed:@"share2.png"] forState:UIControlStateSelected];
    [shareButton addTarget:self action:@selector(clickedShare:)
          forControlEvents:UIControlEventTouchUpInside];
    [shareButton setShowsTouchWhenHighlighted:YES];
    /**
     *  get events detail data from local on basis of eventID
     */
    NSMutableArray *arrayTemp = [[NSMutableArray alloc] initWithArray:[MMdbsupport MMfetchFavEvents:[NSString stringWithFormat:@"select * from ZFAVOURITEEVENTS where ZEVENT_ID = '%@'",[NSNumber numberWithInt:1]]]];
    if ([arrayTemp count]>0) {
        shareButton.selected=YES;
    }
    UIBarButtonItem *shareButtonBar =[[UIBarButtonItem alloc] initWithCustomView:shareButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:shareButtonBar,nil];
    [self addLocationPinOnMap];
}

#pragma mark - Button Clicked
-(IBAction)clickedShare:(id)sender{
    UIButton *btn = (UIButton *)sender;
    
    if (btn.selected) {
        /**
         *  delete event from local to remove from favourites list
         */
        btn.selected=NO;
        [MMdbsupport MMExecuteSqlQuery:[NSString stringWithFormat:@"delete from ZFAVOURITEEVENTS where ZEVENT_ID = '%@'",[NSNumber numberWithInt:1]]];
        [Utility alertNotice:APPNAME withMSG:@"Event remove from favourite" cancleButtonTitle:@"OK" otherButtonTitle:nil];
    }
    else{
        
        /**
         *  add event to local to add in favourites list
         */
        
        btn.selected = YES;
        AppDelegate *appdel = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        FavouriteEvents *objData = [NSEntityDescription insertNewObjectForEntityForName:@"FavouriteEvents" inManagedObjectContext:appdel.managedObjectContext];
        objData.event_all_day       =   [NSNumber numberWithInt:1];
        objData.event_content       =   self.eventObj[@"description"];
        objData.event_end_dateTime  =   self.eventObj[@"to"];
        objData.event_id            =   [NSNumber numberWithInt:1];
        objData.event_image_url     =   @"";
        objData.event_name          =   self.eventObj[@"name"];
        objData.event_owner         =   @"";
        objData.event_start_dateTime=   self.eventObj[@"from"];
        objData.event_loc_address   =   self.eventObj[@"address"];
        objData.event_loc_country   =   @"";
        objData.event_loc_latitude  =   [NSNumber numberWithInt:1];
        objData.event_loc_longitude =   [NSNumber numberWithInt:1];
        objData.event_loc_name      =   self.eventObj[@"location"];
        objData.event_loc_owner     =   @"";
        objData.event_loc_postcode  =   @"";
        objData.event_loc_region    =   @"";
        objData.event_loc_state     =   @"";
        objData.event_loc_town      =   @"";
        
        [appdel.managedObjectContext save:nil];
        
        [Utility alertNotice:APPNAME withMSG:@"Event add as favourite" cancleButtonTitle:@"OK" otherButtonTitle:nil];
    }
}

-(IBAction)btnEventRegistrationPressed:(id)sender
{
//    if ([self checkLogin]) {
//
//        self.arrayTotalSpaces = [[NSMutableArray alloc] init];
//        for (int spaceCount=0; spaceCount<[self.eventObj.eventTicketTotalSpaces intValue]; spaceCount++) {
//            
//            [self.arrayTotalSpaces addObject:[NSString stringWithFormat:@"%d",spaceCount+1]];
//        }
//        
//        self.txtViewComment.layer.borderColor = [UIColor blackColor].CGColor;
//        self.txtViewComment.layer.borderWidth = 1.0f;
//        self.txtViewComment.layer.cornerRadius = 6.0f;
//        
//        [self.eventRegisterView setHidden:NO];
//        
//        if (IS_IPHONE_5) {
//            [self.eventRegisterView setFrame:CGRectMake(self.eventRegisterView.frame.origin.x, self.eventRegisterView.frame.origin.y, self.eventRegisterView.frame.size.width, self.eventRegisterView.frame.size.height+88)];
//            for (UIView *vw in self.eventRegisterView.subviews) {
//                if ([vw isKindOfClass:[UIButton class]]) {
//                }
//            }
//        }
//        else
//        {
//            [self.lblComment setFrame:CGRectMake(self.lblComment.frame.origin.x, self.lblComment.frame.origin.y-35, self.lblComment.frame.size.width, self.lblComment.frame.size.height)];
//            [self.txtViewComment setFrame:CGRectMake(self.txtViewComment.frame.origin.x, self.txtViewComment.frame.origin.y-35, self.txtViewComment.frame.size.width, self.txtViewComment.frame.size.height)];
//        }
//        
//        if (![self.eventObj.eventTicketPrice isKindOfClass:[NSNull class]] && ![self.eventObj.eventTicketPrice isEqualToString:@"(null)"] && [self.eventObj.eventTicketPrice length]>0) {
//            
//            if (![self.eventObj.eventTicketPrice isEqualToString:@"free"] || ![self.eventObj.eventTicketPrice isEqualToString:@"Free"]) {
//            
//                self.lblTotalCost.hidden = NO;
//            
//                [self.lblTotalCost setText:[NSString stringWithFormat:@"Total cost : %@",self.eventObj.eventTicketPrice]];
//            }
//        }
//    }
//    else{
//        [self showLoginScreen];
//    }
}

#pragma mark - Event Registration View Clicked events
-(IBAction)btnCancelPressed:(id)sender
{
  
}

/**
 *  By Tap on submit button user can book ticket for event
 */
-(IBAction)btnSubmitPressed:(id)sender
{
//    if ([self isValid]) {
//        [DSBezelActivityView newActivityViewForView:[UIApplication sharedApplication].keyWindow withLabel:@"Processing..."];
//        
//        NSDictionary *dictOfParameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[Utility getNSUserDefaultValue:KUSERID] intValue]],@"user_id",self.eventObj.eventID,@"event_id",self.txtFieldBookingSpaces.text,@"booking_spaces",self.txtViewComment.text,@"booking_comment", nil];
//
//        [Utility GetDataForMethod:NSLocalizedString(@"BOOKTICKET_METHOD", @"BOOKTICKET_METHOD") parameters:dictOfParameters key:@"" withCompletion:^(id data){
//        
//            [DSBezelActivityView removeViewAnimated:YES];
//            if ([data isKindOfClass:[NSDictionary class]]) {
//                if (self.lblTotalCost.hidden) {
//                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:[data objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                    av.tag = 1001;
//                    [av show];
//                }
//                else
//                {
//                    NSString *strURL = [[data objectForKey:@"payment_page_link"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                    TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:[NSURL URLWithString:strURL]];
//                    webBrowser.delegate = self;
//                    [webBrowser setFixedTitleBarText:@"Book ticket"];
//                    webBrowser.strHtmlContent=@"";
//                    webBrowser.mode = TSMiniWebBrowserModeModal;
//                    webBrowser.barStyle = UIBarStyleDefault;
//                    if (webBrowser.mode == TSMiniWebBrowserModeModal) {
//                        webBrowser.modalDismissButtonTitle = @"Back";
//                        [DSBezelActivityView newActivityViewForView:[UIApplication sharedApplication].keyWindow];
//                        
//                        [self.navigationController presentViewController:webBrowser animated:YES completion:nil];
//                    }
//                    else if(webBrowser.mode == TSMiniWebBrowserModeNavigation) {
//                        [DSBezelActivityView newActivityViewForView:[UIApplication sharedApplication].keyWindow];
//                        [self.navigationController pushViewController:webBrowser animated:YES];
//                    }
//                }
//            }
//   
//        }WithFailure:^(NSString *error){
//            [DSBezelActivityView removeViewAnimated:YES];
//            NSLog(@"%@",error);
//        }];
//    }
}

#pragma mark - TSMiniWebBrowser delegates
-(void)tsMiniWebBrowserDidDismiss
{
//    [DSBezelActivityView newActivityViewForView:[UIApplication sharedApplication].keyWindow withLabel:@"Processing..."];
//    NSDictionary *dictOfParameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[Utility getNSUserDefaultValue:KUSERID] intValue]],@"user_id",self.eventObj.eventID,@"event_id", nil];
//    /**
//     *  This will check, if ticket payment is successful then it return to previous page otherwise it will stay on this page.
//     */
//    [Utility GetDataForMethod:NSLocalizedString(@"CHECKBOOK_METHOD", @"CHECKBOOK_METHOD") parameters:dictOfParameters key:@"" withCompletion:^(id data){
//        [DSBezelActivityView removeViewAnimated:YES];
//        
//        if ([data isKindOfClass:[NSArray class]]) {
//            if ([[[data objectAtIndex:0] objectForKey:@"status"] intValue] == 1) {
//                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:[[data objectAtIndex:0] objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [av setTag:99];
//                [av show];
//            }
//            else{
//                [Utility alertNotice:@"" withMSG:[[data objectAtIndex:0] objectForKey:@"message"] cancleButtonTitle:@"OK" otherButtonTitle:nil];
//            }
//        }
//        
//        if ([data isKindOfClass:[NSDictionary class]]) {
//            if ([[data objectForKey:@"status"] intValue] == 1) {
//                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:[[data objectAtIndex:0] objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [av setTag:99];
//                [av show];
//            }
//            else{
//                [Utility alertNotice:@"" withMSG:[data objectForKey:@"message"] cancleButtonTitle:@"ok" otherButtonTitle:nil];
//            }
//        }
//        
//    }WithFailure:^(NSString *error){
//        [DSBezelActivityView removeViewAnimated:YES];
//        NSLog(@"%@",error);
//    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

}

#pragma mark - Check login for MyFavourite and MyTickets
-(BOOL)checkLogin
{
    NSString *strUserID     =   [NSString stringWithFormat:@"%@",[Utility getNSUserDefaultValue:KUSERID]];
    if ([strUserID length]>0 && ![strUserID isKindOfClass:[NSNull class]] && ![strUserID isEqualToString:@"(null)"]) {
        return YES;
    }
    else
        return NO;
}

/**
 *  Show login view controller with animation
 */
-(void)showLoginScreen
{
    LoginViewController *loginView = [self.storyboard instantiateViewControllerWithIdentifier:@"loginView"];
    loginView.delegate = self;
    UINavigationController *navController   =   [[UINavigationController alloc] initWithRootViewController:loginView];
    
    [UIView transitionWithView:self.view.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ [self.view.window.rootViewController presentViewController:navController animated:NO completion:nil]; }
                    completion:nil];
}

/**
 *  remove login view controller
 */
-(void)dismissLoginView
{
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{ [self dismissViewControllerAnimated:NO completion:nil]; }
                    completion:nil];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.commentUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CommentSummary";
    CommentSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.comment.text = self.commentContents[indexPath.row];
    cell.username.text = self.commentUsers[indexPath.row];
    
    return cell;
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return 20;
}

#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"WhoIsGoingSegue"]) {
        WhoIsGoingViewController *wig = [segue destinationViewController];
        wig.eventImage = self.eventImageView.image;
    } else if ([[segue identifier] isEqualToString:@"AboutDetail"]) {
        DescriptionDetailViewController *dd = [segue destinationViewController];
        dd.eventDescription = self.aboutContent.text;
    }
    
//    ProgramDescriptionViewController *programDescriptionView = [segue destinationViewController];
//    programDescriptionView.strDescription = self.eventObj[@"description"];
    
}
/**
 *  Show event location on map
 */
-(void)addLocationPinOnMap
{
    self.eventLocationMapView.delegate = (id)self;
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta=0.2;
    span.longitudeDelta=0.2;
    
    CLLocationCoordinate2D location =   CLLocationCoordinate2DMake([self.eventObj[@"latitude"] doubleValue], [self.eventObj[@"longitude"] doubleValue]);
    
    region.center = location;
    region.center.latitude  =   location.latitude;
    region.center.longitude =   location.longitude;
    region.span.longitudeDelta=0.04f;
    region.span.latitudeDelta=0.04f;
    
    [self.eventLocationMapView setRegion:region animated:YES];
    MyAnnotation *ann=[[MyAnnotation alloc]init];
    ann.title   =   self.eventObj[@"name"];
    ann.subtitle=@"";
    ann.coordinate=region.center;
    [self.eventLocationMapView addAnnotation:ann];
    [self.eventLocationMapView setRegion:region animated:YES];
}

#pragma mark - MapView Delegates
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if( annotation == mapView.userLocation )
    {
        return nil;
    }
    MyAnnotation *delegate = annotation;  //THIS CAST WAS WHAT WAS MISSING!
    MKPinAnnotationView *annView = nil;
    annView = (MKPinAnnotationView*)[eventLocationMapView dequeueReusableAnnotationViewWithIdentifier:@"eventloc"];
    if( annView == nil ){
        annView = [[MKPinAnnotationView alloc] initWithAnnotation:delegate reuseIdentifier:@"eventloc"];
    }
    
    annView.pinColor = MKPinAnnotationColorGreen;
    annView.animatesDrop=TRUE;
    annView.canShowCallout = YES;
    
    return annView;
}

#pragma mark - Custom Picker and Delegates
-(void)showCustomPicker
{
    CustomPickerView *customPicker;
    CGSize size = [[UIScreen mainScreen] bounds].size;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
        customPicker = [[CustomPickerView alloc] initWithFrame:CGRectMake(0, size.height, 320, 250) delegate:self tag:1];
    }
    else
        customPicker = [[CustomPickerView alloc] initWithFrame:CGRectMake(0, size.height-65, 320, 250) delegate:self tag:1];
    
    [customPicker customPickerAddDataSource:self.arrayTotalSpaces component:0 defaultValue:0];
    [self.view addSubview:customPicker];
    [customPicker showCustomPickerInView:self.view];
}

-(void)customPickerValuePicked:(NSMutableDictionary *)values tag:(int)tag
{
   
}

-(void)customPickerDidCancel
{
   
}

#pragma Text Fields Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField
{

    
    if ([self.arrayTotalSpaces count]>0) {
        [self showCustomPicker];
    }
    else{
        [self.view endEditing:YES];
        [Utility alertNotice:@"" withMSG:@"Not Available" cancleButtonTitle:@"OK" otherButtonTitle:nil];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    [textView endEditing:YES];
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    [textView endEditing:YES];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        return YES;
    }
    return YES;
}

#pragma mark - Validation check
-(BOOL)isValid
{
    return YES;

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.photos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"WhoIsGoing";
    WhoIsGoingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.photo.image = [UIImage imageNamed:[self.photos objectAtIndex:indexPath.row]];
    cell.photo.layer.cornerRadius = cell.photo.frame.size.width / 2;
    cell.photo.clipsToBounds = YES;
    cell.backgroundColor = [UIColor whiteColor];
    
    
    return cell;
}

@end