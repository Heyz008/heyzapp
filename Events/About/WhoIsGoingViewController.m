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
    self.userImages = @[@"222.jpg", @"111.jpg", @"555.jpg", @"444.jpg", @"333.jpg"];
    self.usernames = @[@"Jay Yu", @"Joshua Jiang", @"Eric Liao", @"Daniel Dai", @"Rocky Shi"];
    
    NSArray *photoArray = @[self.connectionView.imageView1, self.connectionView.imageView2, self.connectionView.imageView3, self.connectionView.imageView4, self.connectionView.imageView5];
    
    self.userTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    int i = 0;
    for (UIImageView *imageView in photoArray) {
        imageView.image = [UIImage imageNamed:self.userImages[i]];
        i = i + 1;
        imageView.layer.cornerRadius = imageView.frame.size.width / 2;
        imageView.clipsToBounds = YES;
    }
    
    self.connectionView.imageView1.layer.borderColor = [UIColor orangeColor].CGColor;
    self.connectionView.imageView1.layer.borderWidth = 1.0;
    self.connectionView.imageView3.layer.borderColor = [UIColor orangeColor].CGColor;
    self.connectionView.imageView3.layer.borderWidth = 1.0;
    self.connectionView.imageView2.layer.borderColor = [UIColor greenColor].CGColor;
    self.connectionView.imageView2.layer.borderWidth = 1.0;
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
    cell.photo.layer.cornerRadius = cell.photo.frame.size.width / 2;
    cell.photo.clipsToBounds = YES;
    
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
