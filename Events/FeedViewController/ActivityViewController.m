//
//  ActivityViewController.m
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-29.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import "ActivityViewController.h"
#import "ActivityPhotoCell.h"
#import "ActivityRequestCell.h"
#import "NSString+FontAwesome.h"

@interface ActivityViewController () {
    NSArray *myActivities;
    NSArray *myPhotos;
    NSArray *myImages;
    NSArray *myTypes;
    NSArray *friendActivities;
    NSArray *friendPhotos;
    NSArray *friendImages;
    NSArray *friendTypes;
    NSArray *activities;
    NSArray *photos;
    NSArray *images;
    NSArray *types;
}

@end

@implementation ActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    myActivities = @[@"Rocky Chen wants to join Go CLubbing you hosted.", @"Daniel Dai invited you to join Let's Study.", @"Joshua Jiang sent you a friend request.", @"Jay Chou approved your friend request, you are friends now.", @"Eric Liao liked your photo.", @"Eric Liao comment on your event.", @"Joshua Jiang mentioned you in a comment"];
    myPhotos = @[@"111.jpg", @"222.jpg", @"444.jpg", @"555.jpg", @"333.jpg", @"333.jpg", @"444.jpg"];
    myImages = @[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg", @"2.jpg", @"3.jpg", @"5.jpg"];
    friendActivities = @[@"Rocky Chen joined an event: Let's go Clubbing", @"Daniel Dai hosted an event: Let's Study", @"Joshua Jiang became friend with MoMo Guan", @"Jay Chou liked MoMo Guan's photo", @"Eric Liao post a new photo"];
    friendPhotos = @[@"111.jpg", @"222.jpg", @"444.jpg", @"555.jpg", @"333.jpg"];
    friendImages = @[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg", @"2.jpg"];
    
    myTypes = @[@"1", @"2", @"1", @"1", @"2", @"2", @"2"];
    friendTypes = @[@"1", @"2", @"1", @"1", @"2", @"2", @"2"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    activities = myActivities;
    photos = myPhotos;
    images = myImages;
    types = myTypes;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return photos.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([types[indexPath.row] isEqualToString:@"1"]) {
        ActivityRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityRequestCell" forIndexPath:indexPath];
        
        cell.activity.text = activities[indexPath.row];
        cell.photo.image = [UIImage imageNamed:photos[indexPath.row]];
        cell.photo.layer.cornerRadius = cell.photo.frame.size.width / 2;
        cell.photo.clipsToBounds = YES;
        
        [cell.acceptButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check-circle"] forState:UIControlStateNormal];
        cell.acceptButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:22];
        
        [cell.rejectButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times-circle"] forState:UIControlStateNormal];
        cell.rejectButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:22];
        
        cell.status.hidden = YES;
        
        return cell;
    } else {
        ActivityPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityPhotoCell" forIndexPath:indexPath];
        
        cell.activity.text = activities[indexPath.row];
        cell.photo.image = [UIImage imageNamed:photos[indexPath.row]];
        cell.photo.layer.cornerRadius = cell.photo.frame.size.width / 2;
        cell.photo.clipsToBounds = YES;
        
        cell.image.image = [UIImage imageNamed:images[indexPath.row]];
        
        return cell;
    }
}

-(IBAction)segmentChanged:(id)sender {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
