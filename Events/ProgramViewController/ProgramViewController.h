//
//  ProgramViewController.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-01-24.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTCollectionViewWaterfallLayout.h"
#import "QRCodeReaderViewController.h"
#import "EventMapViewController.h"

@interface ProgramViewController : UICollectionViewController<UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout, QRCodeReaderDelegate>

@end
