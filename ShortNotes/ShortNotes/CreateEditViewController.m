//
//  CreateEditViewController.m
//  ShortNotes
//
//  Created by Sanjith Kanagavel on 26/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "CreateEditViewController.h"

@implementation CreateEditViewController

BOOL keyboardClosed;
BOOL keyboardShown;
SCLAlertView *alertView;
NSUInteger keyBoardHeight;
NSString *cachedString;

#pragma mark - View Functions

/*
 * Function to load base screen
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLocalVariables];
    [self configureBaseScreen];
}

/*
 * Function for Registering keyboard notifications when view appears
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
}

/*
 * Function for Unregistering keyboard notifications when view hides
 */
- (void)viewWillDisappear:(BOOL)animated
{
    [self deregisterFromKeyboardNotifications];
    [super viewWillDisappear:animated];
}

/*
 * Function to init local data required for the view
 */
-(void) initLocalVariables {
    cachedString = self.dataTextStr;
    keyBoardHeight = 0;
    keyboardClosed = true;
    keyboardShown = false;
}

#pragma mark - Base Screen related functions

/*
 * Function for Configuring base screen settings
 */
-(void) configureBaseScreen {
    [Utility styleNaviBar];
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
 * Function for responding to Done button when clicked Keyboard is hidden
 */
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:newLine])
        [textView resignFirstResponder];
    return YES;
}

/*
 * Function triggered when received memory warning
 */
- (void)didReceiveMemoryWarning {
    [Utility showCustomAlert:self image:[UIImage imageNamed:infoButtonLStr] title:memoryWarnTitle subTitle:memoryWarnSubtitle];
    [super didReceiveMemoryWarning];
}

/*
 * Function to hide status bar
 */
-(BOOL)prefersStatusBarHidden{
    return YES;
}


#pragma mark - Keyboard handling functions

/*
 * Function for Registering Keyboard notifications
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
 * Function for Unregistering Keyboard notifications
 */
- (void)deregisterFromKeyboardNotifications
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

/*
 * Function triggers when Keyboard shown
 */
- (void)keyboardDidShow: (NSNotification *) notif{
    keyboardShown = true;
}


/*
 * Function that triggers when keyboard is shown and shrinks the textview accordingly
 */
- (void)keyboardDidChangeFrame:(NSNotification*)notification{
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect keyboardSize = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
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
    if(![cachedString isEqualToString:self.dataText.text]) {
        [Utility showConfirmAlert:self image:[UIImage imageNamed:saveButtonLStr] title:discardDraft subTitle:nil confirmAction:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            } cancelAction:^{}
        ];
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
        NSString * fileName = [NSString stringWithFormat:lldFormat, [@(floor([[NSDate date] timeIntervalSince1970] * 1000)) longLongValue]];
         path = [self.rootPath childPath:[fileName stringByAppendingString:txtFormat]];
         file = [self.fileSystem createFile:path error:&error];
    }
    else {
        path = self.dbFileInfo.path;
        file = [self.fileSystem openFile:path error:&error];
    }
    if(!file) {
        [Utility showCustomAlert:self image:[UIImage imageNamed:infoButtonLStr] title:dataerrorTitle subTitle:dataerrorSubtitle];
    }
    else {
        [file writeContentsOfFile:self.dataText.text shouldSteal:YES error:nil];
        [file close];
        [self.dataText resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
