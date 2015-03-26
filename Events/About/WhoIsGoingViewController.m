//
//  WhoIsGoingViewController.m
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-15.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import "WhoIsGoingViewController.h"
#import "UserCell.h"

@interface WhoIsGoingViewController ()

@end

@implementation WhoIsGoingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userTableView.delegate = self;
    self.userImageView.image = self.eventImage;
    self.userImages = @[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg", @"5.jpg"];
    self.usernames = @[@"Jay Yu", @"Joshua Jiang", @"Eric Liao", @"Daniel Dai", @"Rocky Shi"];
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
    return self.userImages.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    
    cell.username.text = self.usernames[indexPath.row];
    cell.photo.image = [UIImage imageNamed:self.userImages[indexPath.row]];
    
    return cell;
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
