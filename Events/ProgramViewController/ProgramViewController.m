//
//  ProgramViewController.m
//  Heyz
//
//  Created by Joshua Jiang on 2015-01-24.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import "ProgramViewController.h"
#import "ProgramViewController.h"
#import "ProgramMainCell.h"
#import "EventList.h"
#import "MyEventTickets.h"
#import "AboutViewController.h"
#import "UIImageView+WebCache.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "NewEventViewController.h"
#import <Parse/Parse.h>
#import "NSString+FontAwesome.h"
#import "EventSearchViewController.h"

@interface ProgramViewController (){
    NSMutableArray *arrayEventList;
    NSArray *likes;
    NSArray *joins;
}

@end

@implementation ProgramViewController

static NSString * const reuseIdentifier = @"Cell";


- (void)viewDidLoad {

    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;s
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10); //set spacing from edge of screen, 10px from each edge
    layout.minimumColumnSpacing = 7; // space between columns
    layout.minimumInteritemSpacing = 7; // space between rows
    layout.columnCount = 2;
    
    joins = @[@"15", @"36", @"78", @"99", @"22", @"67"];
    likes = @[@"6", @"8", @"9", @"6", @"10", @"5"];
    
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    UIColor *buttonColor = [UIColor colorWithRed:235.0/255 green:108.0/255 blue:118.0/255 alpha:1.0];
    UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-map-marker"] style:UIBarButtonItemStylePlain target:self action:@selector(showMapView)];
    [mapButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:kFontAwesomeFamilyName size:20], NSFontAttributeName,
                                        buttonColor, NSForegroundColorAttributeName,
                                        nil] forState:UIControlStateNormal];
    UIBarButtonItem *qrButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-qrcode"] style:UIBarButtonItemStylePlain target:self action:@selector(qrScan)];
    [qrButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIFont fontWithName:kFontAwesomeFamilyName size:20], NSFontAttributeName,
                                       buttonColor, NSForegroundColorAttributeName,
                                       nil] forState:UIControlStateNormal];
    
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedItem.width = 30.0f;
    
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:mapButton, fixedItem, qrButton, nil]];
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-search"] style:UIBarButtonItemStylePlain target:self action:@selector(searchEvent)];
    [searchButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:kFontAwesomeFamilyName size:20], NSFontAttributeName,
                                          buttonColor, NSForegroundColorAttributeName,
                                          nil] forState:UIControlStateNormal];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-plus"] style:UIBarButtonItemStylePlain target:self action:@selector(addEvent)];
    [addButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:kFontAwesomeFamilyName size:20], NSFontAttributeName,
                                          buttonColor, NSForegroundColorAttributeName,
                                          nil] forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:addButton, fixedItem, searchButton, nil]];
    
    // Do any additional setup after loading the view.
}

-(void)qrScan {
    if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
        static QRCodeReaderViewController *reader = nil;
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            reader                        = [QRCodeReaderViewController new];
            reader.modalPresentationStyle = UIModalPresentationFormSheet;
        });
        reader.delegate = self;
        
        [reader setCompletionWithBlock:^(NSString *resultAsString) {
            NSLog(@"Completion with result: %@", resultAsString);
        }];
        
        [self presentViewController:reader animated:YES completion:NULL];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Reader not supported by the current device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"QRCodeReader" message:result delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)searchEvent {
    EventSearchViewController *es = (EventSearchViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"EventSearch"];
    [self.navigationController pushViewController:es animated:YES];
}

-(void)addEvent {
    NewEventViewController *ne = (NewEventViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"NewEvent"];
    [self.navigationController pushViewController:ne animated:YES];
}

-(void)showMapView {
    EventMapViewController *mvc = [[EventMapViewController alloc] init];
    mvc.eventList = arrayEventList;
    [self.navigationController pushViewController:mvc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self.navigationController.tabBarController.tabBar setHidden:NO];
    
    [Utility afterDelay:0.01 withCompletion:^{
        [DSBezelActivityView newActivityViewForView:self.view.window];
        [self getEventListFromServer];
    }];
}

#pragma mark - Get All Event's from server
-(void)getEventListFromServer
{
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [DSBezelActivityView removeViewAnimated:NO];
        if (!error) {
            arrayEventList = [objects mutableCopy];
            [self.collectionView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [arrayEventList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ProgramMainCell";
    ProgramMainCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    PFFile *userImageFile = [arrayEventList objectAtIndex:indexPath.row][@"image"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            cell.eventImage.image = [UIImage imageWithData:imageData];
        }
    }];
    cell.eventDescription.text = [[arrayEventList objectAtIndex:indexPath.row] objectForKey:@"title"];
    CGRect labelFrame = cell.eventDescription.frame;
    labelFrame.size.height = [self getLabelHeight:labelFrame.size.width withText:cell.eventDescription.text];
    cell.eventDescription.frame = labelFrame;
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.borderWidth=1.0f;
    cell.layer.borderColor=[UIColor colorWithRed:222.0/255 green:222.0/255 blue:222.0/255 alpha:1.0f].CGColor;
    
    cell.eventInfo.font = [UIFont fontWithName:kFontAwesomeFamilyName size:12];
    cell.eventInfo.text = [NSString stringWithFormat:@"%@ %@        %@ %@", [NSString fontAwesomeIconStringForIconIdentifier:@"fa-heart"], joins[indexPath.row], [NSString fontAwesomeIconStringForIconIdentifier:@"fa-user"], likes[indexPath.row]];
    if ([likes[indexPath.row] isEqualToString:@"6"]) {
        cell.eventInfo.textColor = [UIColor colorWithRed:220/255.0 green:20/255.0 blue:60/255.0 alpha:1.0];
    } else {
        cell.eventInfo.textColor = [UIColor grayColor];
    }
    
    CGRect cFrame = cell.eventInfo.frame;
    cFrame.origin.y = cell.eventDescription.frame.origin.y + cell.eventDescription.frame.size.height + 3;
    cell.eventInfo.frame = cFrame;
    
    return cell;
}

-(CGFloat)getLabelHeight:(CGFloat)labelWidth withText:(NSString*)text {
    CGSize maximumLabelSize = CGSizeMake(labelWidth, FLT_MAX);
    
    CGSize expectedLabelSize = [text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByCharWrapping];
    
    //adjust the label the the new height.
    return expectedLabelSize.height;
}

#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"EventDetailsPush"]) {
        ProgramMainCell *cell = (ProgramMainCell*)sender;
        NSIndexPath *selectedRowIndex = [self.collectionView indexPathForCell:cell];
        AboutViewController *aboutVwController = [segue destinationViewController];
        //aboutVwController.hidesBottomBarWhenPushed = YES;
        PFObject *obj  =   [arrayEventList objectAtIndex:selectedRowIndex.row];
        
        aboutVwController.eventObj  =   obj;
    }
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(100, 112 + [self getLabelHeight:140 withText:[arrayEventList objectAtIndex:indexPath.row][@"title"]]);
}


#pragma mark <UICollectionViewDelegate>

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */

@end
