//
//  EventSearchViewController.m
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-20.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import "EventSearchViewController.h"
#import "UserCell.h"

@interface EventSearchViewController ()

@end

@implementation EventSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.categories = @[@"Arts", @"Movies", @"Clubbing", @"Chat", @"Sports", @"Concerts"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tag = 1;
    self.userTableView.tag = 2;
    self.usernames = @[@"Joshua Jiang", @"Joshua Zhang"];
    self.photos = @[@"1.jpg", @"3.jpg"];
    self.seg.selectedSegmentIndex = 0;
    self.userTableView.hidden = YES;
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
    if (tableView.tag == 1) {
        return self.categories.count;
    } else {
        return self.photos.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventSearchCell" forIndexPath:indexPath];
        
        cell.textLabel.text = self.categories[indexPath.row];
        
        return cell;
    } else {
        UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
        
        cell.username.text = self.usernames[indexPath.row];
        cell.photo.image = [UIImage imageNamed:self.photos[indexPath.row]];
        cell.photo.layer.cornerRadius = cell.photo.frame.size.height / 2;
        cell.clipsToBounds = YES;
        
        return cell;
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//
//}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    if (tableView.tag == 1) {
        /* Section header is in 0th index... */
        [label setText:@"Categories"];
    } else {
        [label setText:@"Users"];
    }
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
    return view;
}

-(IBAction)changeSeg{
    if(self.seg.selectedSegmentIndex == 0){
        self.userTableView.hidden = YES;
        self.tableView.hidden = NO;
    }
    if(self.seg.selectedSegmentIndex == 1){
        self.tableView.hidden = YES;
        self.userTableView.hidden = NO;
    }
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
