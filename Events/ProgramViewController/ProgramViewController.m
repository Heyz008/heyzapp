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

@interface ProgramViewController (){
    NSMutableArray *arrayEventList;
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
    
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
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
    cell.eventDescription.text = [[arrayEventList objectAtIndex:indexPath.row] objectForKey:@"description"];
    CGRect labelFrame = cell.eventDescription.frame;
    labelFrame.size.height = [self getLabelHeight:labelFrame.size.width withText:cell.eventDescription.text];
    cell.eventDescription.frame = labelFrame;
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.borderWidth=1.0f;
    cell.layer.borderColor=[UIColor colorWithRed:222.0/255 green:222.0/255 blue:222.0/255 alpha:1.0f].CGColor;
    
    cell.eventInfo.font = [UIFont fontWithName:kFontAwesomeFamilyName size:12];
    cell.eventInfo.text = [NSString stringWithFormat:@"%@ %d        %@ %d", [NSString fontAwesomeIconStringForIconIdentifier:@"fa-heart"], 100, [NSString fontAwesomeIconStringForIconIdentifier:@"fa-user"], 36];
    cell.eventInfo.textColor = [UIColor colorWithRed:220/255.0 green:20/255.0 blue:60/255.0 alpha:1.0];
    
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
        PFObject *obj  =   [arrayEventList objectAtIndex:selectedRowIndex.row];
        
        aboutVwController.eventObj  =   obj;
    }
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(100, 112 + [self getLabelHeight:140 withText:[arrayEventList objectAtIndex:indexPath.row][@"description"]]);
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
