//
//  MyProgramViewController.m
//  Events
//
//  Created by Shabbir Hasan Zaheb on 22/02/14.
//  Copyright (c) 2014 Teknowledge Software. All rights reserved.
//

#import "MyProgramViewController.h"
#import "MyProgramCustomCell.h"
#import "ProgramCustomCell.h"
#import "VRGCalendarView.h"
#import "EventCalCell.h"
#import "UIImageView+WebCache.h"
#import "LoginViewController.h"
#import "MMdbsupport.h"
#import <Parse/Parse.h>
#import "EventList.h"
#import "EventCell.h"
#import "AboutViewController.h"
#import "UIImage+MDQRCode.h"

@interface MyProgramViewController () 
{
    NSMutableDictionary *events;
}
@end

@implementation MyProgramViewController


#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    events = [[NSMutableDictionary alloc] initWithDictionary:@{}];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [DSBezelActivityView removeViewAnimated:NO];
        if (!error) {
            for (PFObject *event in objects) {
                NSString *eventFrom = event[@"from"];
                if (![eventFrom isEqualToString:@""]) {
                    NSString *fromDate = [eventFrom componentsSeparatedByString:@" "][0];
                    if (!events[fromDate]) {
                        events[fromDate] = [@[] mutableCopy];
                    }
                    NSMutableArray *dateEvents = events[fromDate];
                    [dateEvents addObject:event];
                    events[fromDate] = dateEvents;
                }
            }
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [events count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray *keys = [events allKeys];
    return [events[keys[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventCell";
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSArray *keys = [events allKeys];
    PFObject *event = events[keys[indexPath.section]][indexPath.row];
    NSString *eventFrom = event[@"from"];
    NSString *eventTo = event[@"to"];
    NSString *fromTime = [eventFrom componentsSeparatedByString:@" "][1];
    NSString *toTime = [eventTo componentsSeparatedByString:@" "][1];
    cell.start.text = fromTime;
    cell.end.text = toTime;
    if ([event[@"category"] isEqualToString:@"Clubbing"]) {
        cell.seperator.backgroundColor = [UIColor colorWithRed:45.0/255 green:236.0/255 blue:64.0/255 alpha:1.0];
    } else {
        cell.seperator.backgroundColor = [UIColor colorWithRed:192.0/255 green:192.0/255 blue:192.0/255 alpha:1.0];
    }
    cell.eventName.text = event[@"title"];
    PFFile *eventImageFile = event[@"image"];
    [eventImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            cell.eventPoster.image = [UIImage imageWithData:imageData];
        }
    }];
    cell.eventQR.image = [UIImage mdQRCodeForString:event[@"title"] size:cell.eventQR.frame.size.width fillColor:[UIColor darkGrayColor]];
    CGRect qrFrame = cell.eventQR.frame;
    qrFrame.origin.x = cell.frame.size.width - qrFrame.size.width;
    qrFrame.origin.y = cell.frame.size.height - qrFrame.size.height - 3;
    cell.eventQR.frame = qrFrame;
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, tableView.frame.size.width, 13)];
    [label setFont:[UIFont systemFontOfSize:12]];
    NSArray *keys = [events allKeys];
    [label setText:keys[section]];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0]]; //your background color...
    return view;
}

//- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
//{
//    
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
       
    EventCell *cell = (EventCell*)sender;
    NSIndexPath *selectedRowIndex = [self.tableView indexPathForCell:cell];
    AboutViewController *aboutVwController = [segue destinationViewController];
    NSArray *keys = [events allKeys];
    PFObject *event = events[keys[selectedRowIndex.section]][selectedRowIndex.row];
    
    aboutVwController.eventObj  =   event;
}
@end