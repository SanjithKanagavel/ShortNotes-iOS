//
//  CreateEditViewController.m
//  ShortNotes
//
//  Created by Sanjith Kanagavel on 26/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "CreateEditViewController.h"
#import "Constants.h"
#import "SCLAlertView.h"

@implementation CreateEditViewController

BOOL keyboardClosed;
BOOL keyboardShown;
DBFilesystem *filesystem;
SCLAlertView *alertView;
NSUInteger keyBoardHeight;
NSString *cachedString;

#pragma mark - View Functions

/*
* Base function loading base screen
*/
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLocalData];
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

/*
 * Function to init local data required for the view
 */
-(void) initLocalData {
    cachedString = self.dataTextStr;
    keyBoardHeight = 0;
    keyboardClosed = true;
    keyboardShown = false;
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
    self.dataText.text = self.dataTextStr;
    self.navigationBar.topItem.title =  (self.isCreate) ? createStr : editStr ;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
}


/*
 * Unregistering Keyboard notifications
 */

- (void)deregisterFromKeyboardNotifications
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

/*
 * Keyboard Shown
 */
- (void)keyboardDidShow: (NSNotification *) notif{
    keyboardShown = true;
}


/*
 * Triggers when keyboard is shown and shrinks the textview accordingly
 */
- (void)keyboardDidChangeFrame:(NSNotification*)notification{
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect keyboardSize = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"%f",keyboardSize.size.height);
    if( !keyboardShown ) {
        return;
    }
    if( keyboardClosed && keyBoardHeight == keyboardSize.size.height) { // Keyboard height not changed
        return;
    }
    
    NSInteger offsetHeight = 0;
    if(keyBoardHeight == 0) {
        offsetHeight = keyboardSize.size.height;
    }
    else {
        offsetHeight = keyBoardHeight - keyboardSize.size.height;
        offsetHeight *= -1;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    keyBoardHeight = keyboardSize.size.height;
    self.dataText.frame = CGRectMake(self.dataText.frame.origin.x,self.dataText.frame.origin.y,self.dataText.frame.size.width,self.dataText.frame.size.height - offsetHeight);
    if(keyboardClosed) { //scroll only on first keyboard open
        [self.dataText scrollRangeToVisible:[self.dataText selectedRange]];
    }
    [UIView commitAnimations];
    keyboardClosed = false;
}


/*
 * Triggers when keyboard is hidden and expands the textview accordingly
 */
- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    CGRect keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    self.dataText.frame = CGRectMake(self.dataText.frame.origin.x,self.dataText.frame.origin.y,self.dataText.frame.size.width,self.dataText.frame.size.height + keyboardSize.size.height);
    [UIView commitAnimations];
    keyboardShown = false;
    keyboardClosed = true;
    keyBoardHeight = 0;
    
}


#pragma mark - Actions

- (IBAction)returnAction:(id)sender {
    [self.dataText resignFirstResponder];
    if(![cachedString isEqualToString:self.dataText.text])
    {
        alertView = [[SCLAlertView alloc] init];
        alertView.shouldDismissOnTapOutside = YES;
        alertView.showAnimationType = SlideOutFromCenter;
        alertView.hideAnimationType = SlideOutToCenter;
        SCLButton *confirmtButton = [alertView addButton:discard actionBlock:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        SCLButton *cancelButton = [alertView addButton:cancel actionBlock:^{ }];
        ButtonFormatBlock buttonFormatBlock = ^NSDictionary* (void) {
            NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
            buttonConfig[cornerRadiusStr] = logoutBtnCR;
            return buttonConfig;
        };
        
        confirmtButton.buttonFormatBlock = buttonFormatBlock;
        cancelButton.buttonFormatBlock = buttonFormatBlock;
        UIColor *color = [UIColor colorWithRed:65.0/255.0 green:64.0/255.0 blue:144.0/255.0 alpha:1.0];
        [alertView showCustom:self image:[UIImage imageNamed:saveButtonLStr] color:color title:discardDraft subTitle:nil closeButtonTitle:nil duration:0.0f];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)saveAction:(id)sender {
    DBPath *path;
    DBFile *file;
    DBError *error = nil;
    if(self.isCreate) {
        NSString * fileName = [NSString stringWithFormat:@"%lld", [@(floor([[NSDate date] timeIntervalSince1970] * 1000)) longLongValue]];
         path = [self.rootPath childPath:[fileName stringByAppendingString:@".txt"]];
         file = [self.fileSystem createFile:path error:&error];
    }
    else {
        path = self.dbFileInfo.path;
        file = [self.fileSystem openFile:path error:&error];
    }
    
    if (!file) {
        NSLog(@"%@",[[error userInfo] description]);
    }
    [file writeContentsOfFile:self.dataText.text shouldSteal:YES error:nil];
    [file close];
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
