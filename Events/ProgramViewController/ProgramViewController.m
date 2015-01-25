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

@interface ProgramViewController (){
    NSMutableArray *arrayEventList;
    NSArray *images;
    NSArray *descriptions;
}

@end

@implementation ProgramViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    images = [NSArray arrayWithObjects:@"1.jpg", @"2.jpg", @"3.jpg", @"5.jpg", @"4.jpg", nil];
    descriptions = [NSArray arrayWithObjects:@"I knew there was also an ABC party and one of those stupid", @"like the description", @"fringe guests", @"I just want to throw a kick-ass party, and when it comes down to it", @"account", nil];
    
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
    NSDictionary *dictOfEventRequestParameter = [[NSDictionary alloc] initWithObjectsAndKeys:[Utility getNSUserDefaultValue:KUSERID],@"user_id", nil];
    
    [Utility GetDataForMethod:NSLocalizedString(@"GETEVENTS_METHOD", @"GETEVENTS_METHOD") parameters:dictOfEventRequestParameter key:@"" withCompletion:^(id response){
        
        [DSBezelActivityView removeViewAnimated:NO];
        arrayEventList  =   [[NSMutableArray alloc] init];
        
        if ([response isKindOfClass:[NSArray class]]) {
            if ([[[response objectAtIndex:0] allKeys] containsObject:@"status"]) {
                if ([[[response objectAtIndex:0] objectForKey:@"status"] intValue] == 0) {
                    [Utility alertNotice:@"" withMSG:[[response objectAtIndex:0] objectForKey:@"message"] cancleButtonTitle:@"OK" otherButtonTitle:nil];
                    gArrayEvents = [[NSMutableArray alloc] initWithArray:arrayEventList];
                    [self.collectionView reloadData];
                    return ;
                    
                }
            }
            
            NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"event_start_date"  ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
            NSArray *sortedArrayEventList = [response sortedArrayUsingDescriptors:@[descriptor]];
            
            for (NSDictionary *dict in sortedArrayEventList) {
                EventList *eventObj = [[EventList alloc] init];
                eventObj.eventID                =   [NSNumber numberWithInt:[[dict objectForKey:@"event_id"] intValue]];
                eventObj.eventName              =   [dict objectForKey:@"event_name"];
                eventObj.eventImageURL          =   [dict objectForKey:@"event_image_url"];
                eventObj.eventDescription       =   [dict objectForKey:@"event_content"];
                
                //12.15pm 4 June '14
                eventObj.eventStartDateTime     =   [Utility getFormatedDateString:[NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"event_start_date"],[dict objectForKey:@"event_start_time"]] dateFormatString:@"yyyy-MM-dd HH:mm:ss" dateFormatterString:@"HH:mm a - dd MMM yyyy"];
                
                eventObj.eventEndDateTime       =   [Utility getFormatedDateString:[NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"event_end_date"],[dict objectForKey:@"event_end_time"]] dateFormatString:@"yyyy-MM-dd HH:mm:ss" dateFormatterString:@"HH:mm a - dd MMM yyyy"];
                
                eventObj.eventLocationName      =   [dict objectForKey:@"location_name"];
                eventObj.eventLocationAddress   =   [dict objectForKey:@"location_address"];
                eventObj.eventLocationTown      =   [dict objectForKey:@"location_town"];
                eventObj.eventLocationState     =   [dict objectForKey:@"location_state"];
                eventObj.eventLocationCountry   =   [dict objectForKey:@"location_country"];
                eventObj.eventLocationLatitude  =   [NSNumber numberWithFloat:[[dict objectForKey:@"location_latitude"] floatValue]];
                eventObj.eventLocationLongitude =   [NSNumber numberWithFloat:[[dict objectForKey:@"location_longitude"] floatValue]];
                
                if ([[dict objectForKey:@"ticket"] count]>0) {
                    NSDictionary *dictOfTicket  =   [[NSDictionary alloc] initWithDictionary:[dict objectForKey:@"ticket"]];
                    eventObj.eventTicketName            =   [dictOfTicket objectForKey:@"ticket_name"];
                    eventObj.eventTicketDescription     =   [dictOfTicket objectForKey:@"ticket_description"];
                    eventObj.eventTicketPrice           =   [dictOfTicket objectForKey:@"ticket_price"];
                    eventObj.eventTicketStart           =   [dictOfTicket objectForKey:@"ticket_start"];
                    eventObj.eventTicketEnd             =   [dictOfTicket objectForKey:@"ticket_end"];
                    eventObj.eventTicketMembers         =   [dictOfTicket objectForKey:@"ticket_members_roles"];
                    eventObj.eventTicketGuests          =   [dictOfTicket objectForKey:@"ticket_guests"];
                    eventObj.eventTicketRequired        =   [dictOfTicket objectForKey:@"ticket_required"];
                    eventObj.eventTicketAvailSpaces     =   [NSNumber numberWithInt:[[dictOfTicket objectForKey:@"avail_spaces"] intValue]];
                    eventObj.eventTicketBookedSpaces    =   [NSNumber numberWithInt:[[dictOfTicket objectForKey:@"booked_spaces"] intValue]];
                    eventObj.eventTicketTotalSpaces     =   [NSNumber numberWithInt:[[dictOfTicket objectForKey:@"total_spaces"] intValue]];
                }
                
                [arrayEventList addObject:eventObj];
            }
        }
        
        /**
         *  global array for events data.
         */
        gArrayEvents = [[NSMutableArray alloc] initWithArray:arrayEventList];
        
        [self.collectionView reloadData];
        
    }WithFailure:^(NSString *error)
     {
         [DSBezelActivityView removeViewAnimated:NO];
         NSLog(@"%@",error);
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
    
    return [images count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ProgramMainCell";
    ProgramMainCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    EventList *obj = [arrayEventList objectAtIndex:indexPath.row];
    
//    if ([obj.eventImageURL length]>0) {
//        [cell.eventImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",obj.eventImageURL]] placeholderImage:nil];
//        [cell.eventImage setContentMode:UIViewContentModeScaleAspectFit];
//        [cell.eventImage setClipsToBounds:YES];
//    }
    cell.eventImage.image = [UIImage imageNamed:[images objectAtIndex:indexPath.row]];
    cell.eventDescription.text = [descriptions objectAtIndex:indexPath.row];
    CGRect labelFrame = cell.eventDescription.frame;
    labelFrame.size.height = [self getLabelHeight:labelFrame.size.width withText:cell.eventDescription.text];
    cell.eventDescription.frame = labelFrame;
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.borderWidth=1.0f;
    cell.layer.borderColor=[UIColor colorWithRed:222.0/255 green:222.0/255 blue:222.0/255 alpha:1.0f].CGColor;
    
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
    //    // Get the new view controller using [segue destinationViewController].
    //    // Pass the selected object to the new view controller.
    //
    ProgramMainCell *cell = (ProgramMainCell *)sender;
    NSIndexPath *selectedRowIndex = [self.collectionView indexPathForCell:cell];
    AboutViewController *aboutVwController = [segue destinationViewController];
    EventList *obj  =   [arrayEventList objectAtIndex:selectedRowIndex.row];
    
    aboutVwController.eventObj  =   obj;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(100, 100 + [self getLabelHeight:140 withText:[descriptions objectAtIndex:indexPath.row]]);
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
