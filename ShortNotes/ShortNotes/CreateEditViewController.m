//
//  CreateEditViewController.m
//  ShortNotes
//
//  Created by Sanjith Kanagavel on 26/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "CreateEditViewController.h"
#import "Constants.h"
@implementation CreateEditViewController

BOOL keyboardChanged = false;

#pragma mark - View Functions

/*
* Base function loading base screen
*/
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureBaseScreen];
}

/*
 * Registering keyboard notifications when view appears
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
}

/*
 * Unregistering keyboard notifications when view hides
 */
- (void)viewWillDisappear:(BOOL)animated
{
    [self deregisterFromKeyboardNotifications];
    [super viewWillDisappear:animated];
}

#pragma mark - Base Screen related functions

/*
 * Configuring base screen settings
 */
-(void) configureBaseScreen {
  [self styleNaviBar];
  self.dataText.font = [UIFont fontWithName:fontName size:20.0];
    [self.dataText setUserInteractionEnabled:YES];
    self.dataText.scrollEnabled = NO;
    self.dataText.scrollEnabled = YES;
    [self.dataText sizeToFit];
    [self.dataText setContentInset:UIEdgeInsetsMake(-10.0, 0, -5.0, 0)];
    self.dataText.delegate = self;

}

/*
 * Styling function for NavigationBar
 */
-(void) styleNaviBar {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:naviTxt] forBarMetrics:UIBarMetricsDefault];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:fontName size:21.0], NSFontAttributeName, nil]];
}

/*
 * Responding to Done button when clicked Keyboard is hidden
 */
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:newLine])
        [textView resignFirstResponder];
    return YES;
}

#pragma mark - Keyboard handling functions

/*
 * Registering Keyboard notifications
 */
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeInputMode:)
                                                 name:UITextInputCurrentInputModeDidChangeNotification object:nil];
}

/*
 * Unregistering Keyboard notifications
 */

- (void)deregisterFromKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextInputCurrentInputModeDidChangeNotification object:nil];
}

/*
 * Triggers when keyboard is shown and shrinks the textview accordingly
 */
- (void)keyboardWasShown:(NSNotification *)notification
{
    if(keyboardChanged) {
        keyboardChanged = NO;
        return;
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGRect keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    self.dataText.frame = CGRectMake(self.dataText.frame.origin.x,self.dataText.frame.origin.y,self.dataText.frame.size.width,self.dataText.frame.size.height - keyboardSize.size.height);
    [self.dataText scrollRangeToVisible:[self.dataText selectedRange]];
    [UIView commitAnimations];
}

/*
 * Triggers when keyboard is hidden and expands the textview accordingly
 */
- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGRect keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    self.dataText.frame = CGRectMake(self.dataText.frame.origin.x,self.dataText.frame.origin.y,self.dataText.frame.size.width,self.dataText.frame.size.height + keyboardSize.size.height);
    [UIView commitAnimations];
}

/*
 * Detecting language change in keyboard so as to adjust textview height
 */
-(void)changeInputMode:(NSNotification *)notification
{
    keyboardChanged = YES;
}

#pragma mark - Actions

- (IBAction)returnAction:(id)sender {
    [self.dataText resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveAction:(id)sender {
    [self.dataText resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Other View Functions

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(BOOL)prefersStatusBarHidden{
    return YES;
}


@end
