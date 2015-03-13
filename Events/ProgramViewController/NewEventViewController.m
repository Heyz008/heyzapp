//
//  NewEventViewController.m
//  Heyz
//
//  Created by Joshua Jiang on 2015-01-29.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import "NewEventViewController.h"
#import <Parse/Parse.h>
#import "MyAnnotation.h"
#import "ASIHTTPRequest.h"
#import "SBJSON.h"
#import "M13Checkbox.h"

@interface NewEventViewController ()<EventLocationViewControllerDelegate>

@end

@implementation NewEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat fieldOriginX = self.eventName.frame.origin.x;
    CGFloat fieldWidth = self.eventName.frame.size.width;
    
    M13Checkbox *checkBox = [[M13Checkbox alloc] initWithTitle:@"This is an online event"];
    checkBox.titleLabel.font = [UIFont systemFontOfSize:14];
    checkBox.strokeColor = [UIColor blackColor];
    checkBox.checkColor = [UIColor blackColor];
    [checkBox setCheckAlignment:M13CheckboxAlignmentLeft];
    checkBox.frame = CGRectMake(fieldOriginX, self.eventLocationButton.frame.origin.y + self.eventLocationButton.frame.size.height + 6, fieldWidth, 14);
    [self.eventScrollView addSubview:checkBox];
    
    self.startDate.backgroundColor = [UIColor whiteColor];
    [self.startDate setTitle:@" Starts" forState:UIControlStateNormal];
    self.startDate.titleLabel.textAlignment = UIControlContentHorizontalAlignmentLeft;
    self.startDate.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.startDate setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.startDate.layer.borderColor = [UIColor blackColor].CGColor;
    self.startDate.layer.borderWidth = 1.0f;
    
    UIDatePicker *view2 = [[UIDatePicker alloc] init];
    view2.backgroundColor = [UIColor whiteColor];
    view2.tag = 1;
    [view2 addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.endDate setTitle:@" Ends" forState:UIControlStateNormal];
    self.endDate.backgroundColor = [UIColor whiteColor];
    self.endDate.titleLabel.font = [UIFont systemFontOfSize:14];
    self.endDate.titleLabel.textAlignment = UIControlContentHorizontalAlignmentLeft;
    self.endDate.layer.borderColor = [UIColor blackColor].CGColor;
    [self.endDate setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.endDate.layer.borderWidth = 1.0f;
    
    UIDatePicker *view3 = [[UIDatePicker alloc] init];
    view3.backgroundColor = [UIColor whiteColor];
    view3.tag = 2;
    [view3 addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolBar.barStyle = UIBarStyleBlackOpaque;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched:)];
    
    // the middle button is to make the Done button align to right
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];
    
    self.eventFrom.inputView = view2;
    self.eventTo.inputView = view3;
    self.eventFrom.inputAccessoryView = toolBar;
    self.eventTo.inputAccessoryView = toolBar;
    
    self.eventLocationButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.eventLocationButton.layer.borderWidth = 1.0f;
    
    self.uploadButton.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.eventName resignFirstResponder];
    [self.eventDescription resignFirstResponder];
}

- (void)cancelTouched:(UIBarButtonItem *)sender
{
    // hide the picker view
    [self.eventFrom resignFirstResponder];
    [self.eventTo resignFirstResponder];
}

- (void)doneTouched:(UIBarButtonItem *)sender
{
    // hide the picker view
    [self.eventFrom resignFirstResponder];
    [self.eventTo resignFirstResponder];
    
    // perform some action
}

- (IBAction)fromSelect:(id)sender {
    [self.eventFrom becomeFirstResponder];
}

- (IBAction)toSelect:(id)sender {
    [self.eventTo becomeFirstResponder];
}


- (IBAction)photoButtonTapped:(id)sender {
  
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Upload Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Choose Photo From Library",
                            @"Take Photo",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (IBAction)cancleButtonTapped:(id)sender {
    NSLog(@"def");
}

- (void)locationSeleted: (NSString *)location {
    [self.eventLocationButton setTitle:location forState:UIControlStateNormal];
}

- (void)dateChanged:(UIDatePicker *)datePicker
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:datePicker.date];
    if (datePicker.tag == 1) {
        [self.startDate setTitle:[NSString stringWithFormat:@" Starts            %@", strDate] forState:UIControlStateNormal];
    } else if (datePicker.tag == 2) {
        [self.endDate setTitle:[NSString stringWithFormat:@" Ends              %@", strDate] forState:UIControlStateNormal];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"LocationSelect"]) {
        EventLocationViewController *el = [segue destinationViewController];
        el.delegate = self;
    }
}


@end
