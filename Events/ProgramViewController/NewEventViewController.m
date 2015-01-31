//
//  NewEventViewController.m
//  Heyz
//
//  Created by Joshua Jiang on 2015-01-29.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import "NewEventViewController.h"

@interface NewEventViewController ()

@end

@implementation NewEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGSize eventScrollContentSize = self.eventScrollView.frame.size;
    eventScrollContentSize.height = 752;
    self.eventScrollView.contentSize = eventScrollContentSize;
    
    self.eventScrollView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    CountryPicker *pickerView = [[CountryPicker alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    self.eventCountryLabel.frame = CGRectMake(0, 0, 0, 0);
    
    // set change the inputView (default is keyboard) to UIPickerView
    self.eventCountryLabel.inputView = pickerView;
    
    // add a toolbar with Cancel & Done button
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolBar.barStyle = UIBarStyleBlackOpaque;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched:)];
    
    // the middle button is to make the Done button align to right
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];
    self.eventCountryLabel.inputAccessoryView = toolBar;
}

- (void)cancelTouched:(UIBarButtonItem *)sender
{
    // hide the picker view
    [self.eventCountryLabel resignFirstResponder];
}

- (void)doneTouched:(UIBarButtonItem *)sender
{
    // hide the picker view
    [self.eventCountryLabel resignFirstResponder];
    
    // perform some action
}

- (void)countryPicker:(__unused CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code
{
    self.eventCountryName.text = name;
}

-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.eventTitle resignFirstResponder];
    [self.eventLocation resignFirstResponder];
    [self.eventAddress resignFirstResponder];
    [self.eventCity resignFirstResponder];
    [self.eventTags resignFirstResponder];
    [self.eventCountryLabel resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancleButtonTapped:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)createEvent:(id)sender {
    NSLog(@"%@, %@", self.eventTitle.text, self.eventLocation.text);
}


- (IBAction)countrySelect:(id)sender {
    [self.eventCountryLabel becomeFirstResponder];
}

- (IBAction)fromSelect:(id)sender {
    
}

- (IBAction)toSelect:(id)sender {
    
}

- (IBAction)categorySelect:(id)sender {
    
}

- (IBAction)photoSelect:(id)sender {
    
}

- (IBAction)ourPhotoSelect:(id)sender {
    
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
