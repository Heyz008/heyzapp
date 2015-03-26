//
//  SelectTableViewController.m
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-04.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import "SelectTableViewController.h"

@interface SelectTableViewController ()

@end

@implementation SelectTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.selection.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.selection[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.type isEqualToString:@"privacy"]) {
        if ([_delegate respondsToSelector:@selector(privacySelected:withIndex:)]) {
            [_delegate privacySelected:self.selection[indexPath.row] withIndex:indexPath.row];
        }
    } else if ([self.type isEqualToString:@"category"]) {
        if ([_delegate respondsToSelector:@selector(categorySelected:withIndex:)]) {
            [_delegate categorySelected:self.selection[indexPath.row] withIndex:indexPath.row];
        }
    } else if ([self.type isEqualToString:@"maximum"]) {
        if ([_delegate respondsToSelector:@selector(maximumSelected:withIndex:)]) {
            [_delegate maximumSelected:self.selection[indexPath.row] withIndex:indexPath.row];
        }
    } else if ([self.type isEqualToString:@"payment"]) {
        if ([_delegate respondsToSelector:@selector(paymentSelected:withIndex:)]) {
            [_delegate paymentSelected:self.selection[indexPath.row] withIndex:indexPath.row];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
