//
//  ViewController.m
//  ShortNotes
//
//  Created by Sanjith Kanagavel on 25/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//
#import "CreateEditViewController.h"
#import "ViewController.h"
#import "NoteViewCell.h"
#import "SCLAlertView.h"
#import "Constants.h"
#import "CustomRowAction.h"

@implementation ViewController

double SCREEN_CENTER_X;
double SCREEN_CENTER_Y;

SCLAlertView *alert;
UIView *syncStatusView;
UIView *loginView;
NSArray *colors;
NSUInteger colorIndex;

#pragma mark - View Functions
/*
 * Base function loading login screen and base screen
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLocalVariables];
    [self configureBaseScreen];
    
    if(false) {
        [self showLoginScreen];
    }
    //[self showSyncStatus];
}

/*
 * Function after loading but before viewing
 */
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


/*
 * Loading the custom alertview because of performance purpose
 */
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    alert = [[SCLAlertView alloc] init];
}

#pragma mark - Sync Status Functions

/*
 * Function declaration of SyncStatusBar
 */
-(void) showSyncStatus {
    UIView *c1,*c2,*c3;
    if(syncStatusView == nil) {
     syncStatusView = [[UIView alloc]initWithFrame:CGRectMake(0,self.naviBar.frame.size.height, SCREEN_CENTER_X*2, 30)];
    }
    float statusCenterX = syncStatusView.frame.size.width/2;
    
    [syncStatusView setBackgroundColor:[self colorFromHexString:orangeColor1]];
    c1 = [[UIView alloc]initWithFrame:CGRectMake(statusCenterX-10,5,20,20)];
    c1.layer.cornerRadius=10;
    [c1 setBackgroundColor:[self colorFromHexString:orangeColor2]];
    c2 = [[UIView alloc]initWithFrame:CGRectMake(statusCenterX+30,5,20,20)];
    c2.layer.cornerRadius=10;
    [c2 setBackgroundColor:[self colorFromHexString:orangeColor2]];
    
    c3 = [[UIView alloc]initWithFrame:CGRectMake(statusCenterX-50,5,20,20)];
    c3.layer.cornerRadius=10;
    [c3 setBackgroundColor:[self colorFromHexString:orangeColor2]];
    c1.alpha = 0;
    c2.alpha = 0;
    c3.alpha = 0;
    [syncStatusView addSubview:c3];
    [syncStatusView addSubview:c2];
    [syncStatusView addSubview:c1];
    syncStatusView.alpha = 0.8;
    [self.view insertSubview:syncStatusView atIndex:1];
    [self syncStatusAnimation:c1 secondCircle:c2 thridCircle:c3];
}

/*
 * SyncStatusBar Animation
 */
-(void) syncStatusAnimation : (UIView *) c1 secondCircle:(UIView *) c2 thridCircle :(UIView *) c3 {
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [c1 setAlpha:1];
        [c2 setAlpha:0];
        [c3 setAlpha:0];
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [c2 setAlpha:1];
            [c1 setAlpha:0];
            [c3 setAlpha:0];
        } completion:^(BOOL finished){
            
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [c3 setAlpha:1];
                [c1 setAlpha:0];
                [c2 setAlpha:0];
            } completion:^(BOOL finished){
                [self syncStatusAnimation:c1 secondCircle:c2 thridCircle:c3];
            }];
        }];
    }];
}

/*
 * Hide SyncStatusBar and Animation
 */
-(void) hideSyncStatus {
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [syncStatusView setFrame:CGRectMake(syncStatusView.frame.origin.x, syncStatusView.frame.origin.y-30, syncStatusView.frame.size.width,syncStatusView.frame.size.height )];
    } completion:^(BOOL finished){
        [syncStatusView removeFromSuperview];
        syncStatusView = nil;
    }];
}

#pragma mark - Screen Functions

/*
 * Function for configuring base screen
 */
-(void) configureBaseScreen {
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setBackgroundImage:[UIImage imageNamed:addNoteBtn] forState:UIControlStateNormal];
    [addButton setFrame:CGRectMake(0,0,60, 60)];
    [addButton setCenter:CGPointMake((SCREEN_CENTER_X*2)-40, (SCREEN_CENTER_Y*2)-40)];
    [addButton addTarget:self action:@selector(createNewNoteAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
    [self styleNaviBar];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView registerClass:[NoteViewCell class] forCellReuseIdentifier:NoteViewCellStr];
}

/*
 * Function to show Login Screen
 */
-(void) showLoginScreen {
    loginView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,self.view.frame.size.width, self.view.frame.size.height)];
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = loginView.bounds;
    UIImageView *loginImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconImg]];
    [loginImage setFrame:CGRectMake(0, 0, 100, 100)];
    [loginImage setCenter:CGPointMake(SCREEN_CENTER_X,SCREEN_CENTER_Y)];
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setBackgroundImage:[UIImage imageNamed:loginBtn] forState:UIControlStateNormal];
    loginButton.frame = CGRectMake(0, 0, 210, 55);
    [loginButton setCenter:CGPointMake(SCREEN_CENTER_X,(SCREEN_CENTER_Y*2)-100)];
    [loginButton addTarget:self action:@selector(hideLoginScreen) forControlEvents:UIControlEventTouchUpInside];
    [loginView addSubview:visualEffectView];
    [loginView addSubview:loginImage];
    [loginView addSubview:loginButton];
    [self.view addSubview:loginView];
    loginView.alpha = 1;
}

/*
 * Function to hide Login Screen
 */
-(void) hideLoginScreen {
    loginView.alpha = 1;
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        loginView.alpha = 0;
        loginView = nil;
    } completion:nil];
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


#pragma mark - Actions

/*
 * Function to create new note
 */
-(void) createNewNoteAction {
   [self _presentWithSegueIdentifier:showCreateEditStr animated:NO];
}

/*
 * Function to show info alert section
 */
- (IBAction)infoAction:(id)sender {
    alert = [[SCLAlertView alloc] init];
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SlideOutFromCenter;
    alert.hideAnimationType = SlideOutToCenter;
    UIColor *color = [UIColor colorWithRed:65.0/255.0 green:64.0/255.0 blue:144.0/255.0 alpha:1.0];
    [alert showCustom:self image:[UIImage imageNamed:infoButtonLStr] color:color title:infoTitle subTitle:infoSubtitle closeButtonTitle:nil duration:0.0f];
}

/*
 * Function to show logout alert section
 */
- (IBAction)logoutAction:(id)sender {
    alert = [[SCLAlertView alloc] init];
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SlideOutFromCenter;
    alert.hideAnimationType = SlideOutToCenter;
    SCLButton *logoutButton = [alert addButton:confirm actionBlock:^{ }];
    SCLButton *cancelButton = [alert addButton:cancel actionBlock:^{ }];
    ButtonFormatBlock buttonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[cornerRadiusStr] = logoutBtnCR;
        return buttonConfig;
    };
    
    logoutButton.buttonFormatBlock = buttonFormatBlock;
    cancelButton.buttonFormatBlock = buttonFormatBlock;

    UIColor *color = [UIColor colorWithRed:65.0/255.0 green:64.0/255.0 blue:144.0/255.0 alpha:1.0];
    [alert showCustom:self image:[UIImage imageNamed:logoutButtonLStr] color:color title:logoutTitle subTitle:nil closeButtonTitle:nil duration:0.0f];
}

/*
 * Delete note action
 */
-(void) deleteTaskAction {
    alert = [[SCLAlertView alloc] init];
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SlideOutFromCenter;
    alert.hideAnimationType = SlideOutToCenter;
    SCLButton *confrimButton = [alert addButton:confirm actionBlock:^{
        [self.tableView setEditing:NO animated:YES];
    }];
    SCLButton *cancelButton = [alert addButton:cancel actionBlock:^{
    }];
    
    ButtonFormatBlock buttonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[cornerRadiusStr] = logoutBtnCR;
        return buttonConfig;
    };
    confrimButton.buttonFormatBlock = buttonFormatBlock;
    cancelButton.buttonFormatBlock = buttonFormatBlock;
    
    UIColor *color = [UIColor colorWithRed:65.0/255.0 green:64.0/255.0 blue:144.0/255.0 alpha:1.0];
    [alert showCustom:self image:[UIImage imageNamed:deleteBtn] color:color title:confirmDelete subTitle:nil closeButtonTitle:nil duration:0.0f];
}

#pragma mark - UITableView Functions

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (colorIndex >= colors.count) {
        colorIndex = 0;
    }
    
    NoteViewCell *cell;
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:NoteViewCellStr owner:self options:nil];
    cell = [nib objectAtIndex:0];
    [cell setViewColour:[self colorForName:colors[colorIndex]]];
    colorIndex++;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    CustomRowAction *add = [CustomRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:deleteStr icon:[UIImage imageNamed:deleteBtn] handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            [self deleteTaskAction];
    }];
    add.backgroundColor = UIColor.orangeColor;
    return @[add];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        
}

- (void)_presentWithSegueIdentifier:(NSString *)segueIdentifier animated:(BOOL)animated
{
    if (animated) {
        [self performSegueWithIdentifier:segueIdentifier sender:nil];
    } else {
        [UIView performWithoutAnimation:^{
            [self performSegueWithIdentifier:segueIdentifier sender:nil];
        }];
    }
}

#pragma mark - Other View Functions

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - Utility function

/*
 * Function to create UIColor using Hex Value
 */
- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

/*
 * Function to load material colours for rows
 */

- (UIColor *)colorForName:(NSString *)name {
    NSString *sanitizedName = [name stringByReplacingOccurrencesOfString:space withString:emptyStr];
    NSString *selectorString = [NSString stringWithFormat:flatColorFormat, sanitizedName];
    Class colorClass = [UIColor class];
    return [colorClass performSelector:NSSelectorFromString(selectorString)];
}


/*
 * Function for setting local variables like screen center x - y
 */
-(void) initLocalVariables {
    SCREEN_CENTER_X=[[UIScreen mainScreen]bounds].size.width/2;
    SCREEN_CENTER_Y=[[UIScreen mainScreen]bounds].size.height/2;
    colors = @[
               @"Turquoise",
               @"Green Sea",
               @"Emerald",
               @"Nephritis",
               @"Peter River",
               @"Belize Hole",
               @"Amethyst",
               @"Wisteria",
               @"Wet Asphalt",
               @"Midnight Blue",
               @"Sun Flower",
               @"Orange",
               @"Carrot",
               @"Pumpkin",
               @"Alizarin",
               @"Pomegranate",
               @"Concrete",
               @"Asbestos"
               ];
    colorIndex = 0;
}




@end
