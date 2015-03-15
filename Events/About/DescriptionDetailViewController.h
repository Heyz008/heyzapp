//
//  DescriptionDetailViewController.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-15.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DescriptionDetailViewController : UIViewController

@property (nonatomic, strong) NSString *eventDescription;
@property (nonatomic, strong) IBOutlet UITextView *textView;

@end
