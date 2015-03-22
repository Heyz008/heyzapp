//
//  ImageGalleryViewController.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-22.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageGalleryViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) NSArray *galleries;
@property (nonatomic, strong) IBOutlet UIPageControl* pageControl;

- (IBAction)changePage;

@end
