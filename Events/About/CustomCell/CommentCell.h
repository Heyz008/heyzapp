//
//  CommentCell.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-15.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UILabel *commentUser;
@property (strong, nonatomic) IBOutlet UILabel *commentDetail;
@property (strong, nonatomic) IBOutlet UIImageView *commentUserPhoto;


@end
