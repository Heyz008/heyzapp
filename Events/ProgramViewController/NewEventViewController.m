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
#import "NewEventSecondViewController.h"

@interface NewEventViewController ()<EventLocationViewControllerDelegate> {
    CGFloat latitude;
    CGFloat longitude;
    NSString *eventStart;
    NSString *eventEnd;
    UIImage *eventImage;
}

@end

@implementation NewEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat fieldOriginX = self.eventName.frame.origin.x;
    CGFloat fieldWidth = self.eventName.frame.size.width;
    
    self.eventDescription.tag = 99;
    self.eventDescription.delegate = self;
    
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
    
    self.uploadButton.layer.borderWidth = 1.0;
    self.uploadButton.layer.cornerRadius = 12.0;
    
    self.onlineEventView.layer.borderWidth = 1.0;
    self.onlineEventView.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.eventSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
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
                case 0: {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        
                        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
                        picker.delegate = self;
                        picker.allowsEditing=YES;
                        picker.sourceType = sourceType;
                        [self presentViewController:picker animated:YES completion:nil];
                    }
                }
                case 1:{
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
                        
                        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
                        picker.delegate = self;
                        picker.allowsEditing=YES;
                        picker.sourceType = sourceType;
                        [self presentViewController:picker animated:YES completion:nil];
                    }
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    eventImage = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.uploadButton setBackgroundImage:eventImage forState:UIControlStateNormal];
    [self.uploadButton setTitle:@"" forState:UIControlStateNormal];
}

- (IBAction)cancleButtonTapped:(id)sender {
    NSLog(@"def");
}

-(void)locationSeleted:(NSString*)location latitude:(CGFloat)latitude1 longitude:(CGFloat)longitude1 {
    [self.eventLocationButton setTitle:location forState:UIControlStateNormal];
    latitude = latitude1;
    longitude = longitude1;
}

- (void)dateChanged:(UIDatePicker *)datePicker
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:datePicker.date];
    if (datePicker.tag == 1) {
        eventStart = strDate;
        [self.startDate setTitle:[NSString stringWithFormat:@" Starts            %@", strDate] forState:UIControlStateNormal];
    } else if (datePicker.tag == 2) {
        eventEnd = strDate;
        [self.endDate setTitle:[NSString stringWithFormat:@" Ends              %@", strDate] forState:UIControlStateNormal];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 99) {
        CGRect newFrame = self.eventScrollView.frame;
        newFrame.origin.y = self.eventScrollView.frame.origin.y - 200;
        self.eventScrollView.frame = newFrame;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 99) {
        CGRect newFrame = self.eventScrollView.frame;
        newFrame.origin.y = self.eventScrollView.frame.origin.y + 200;
        self.eventScrollView.frame = newFrame;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"LocationSelect"]) {
        EventLocationViewController *el = [segue destinationViewController];
        el.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"NewEvent"]) {
        NewEventSecondViewController *ne = [segue destinationViewController];
        ne.eName = self.eventName.text;
        ne.eDescription = self.eventDescription.text;
        ne.eLatitude = latitude;
        ne.eLongitude = longitude;
        ne.eStart = eventStart;
        ne.eEnd = eventEnd;
        ne.eImage = eventImage;
        ne.eAddress = self.eventLocationButton.titleLabel.text;
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"NewEvent"]) {
        if (!(self.eventName.text && self.eventDescription.text && latitude && longitude && eventStart && eventEnd && eventImage && self.eventLocationButton.titleLabel.text)) {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                              message:@"Please fill in all the fields"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            
            [message show];
            return NO;
        }
    }
    
    return YES;
}


@end
