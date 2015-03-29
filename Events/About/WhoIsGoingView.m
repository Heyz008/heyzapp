//
//  WhoIsGoingView.m
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-29.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import "WhoIsGoingView.h"

@implementation WhoIsGoingView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CAShapeLayer *circle = [CAShapeLayer layer];
    CAShapeLayer *circle2 = [CAShapeLayer layer];
    CGFloat radius1 = 50.0;
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width / 2 - radius1, self.frame.size.height / 2 - radius1, 2.0*radius1, 2.0*radius1) cornerRadius:radius1].CGPath;
    CGFloat radius2 = 90.0;
    circle2.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width / 2 - radius2, self.frame.size.height / 2 - radius2, 2.0*radius2, 2.0*radius2) cornerRadius:radius2].CGPath;
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [UIColor orangeColor].CGColor;
    circle.lineWidth = 1;
    circle.lineDashPattern = @[@2, @3];
    circle2.fillColor = [UIColor clearColor].CGColor;
    circle2.strokeColor = [UIColor blackColor].CGColor;
    circle2.lineWidth = 1;
    circle2.lineDashPattern = @[@2, @3];
    // Add to parent layer
    [[self layer] addSublayer:circle];
    [[self layer] addSublayer:circle2];
}


@end
