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
#import "Dropbox/Dropbox.h"
#import "NoteData.h"

@implementation ViewController

SCLAlertView *alert;

DBAccountManager *accountManager;

UIView *syncStatusView;
UIView *loginView;
UILabel *noNoteTextLbl;

NSArray *colors;
NSMutableArray *notesArray;
NSUInteger deleteIndex;
NSUInteger clickIndex;
BOOL isCreate = true;
BOOL isSyncing = false;

double SCREEN_CENTER_X;
double SCREEN_CENTER_Y;

#pragma mark - View Functions
/*
 * Base function loading login screen and base screen
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLocalVariables];
    [self configureBaseScreen];
    [self getDropboxAccount];
    if(!self.account) {
        [self showLoginScreen];
    }
    else {
        [self dropBoxInit];
    }
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
    else {
        return;
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
    if(!syncStatusView) {
        return;
    }
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
    if(loginView) {
        return ;
    }
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
    [loginButton addTarget:self action:@selector(loginDropBox) forControlEvents:UIControlEventTouchUpInside];
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
    if(!loginView) {
        return;
    }
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        loginView.alpha = 0;
        [loginView removeFromSuperview];
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
    isCreate = true;
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
 * Login Dropbox Function
 */
- (void) loginDropBox {
    if(self.account) {
        [self hideLoginScreen];
        return;
    }
    [accountManager linkFromController:self];
}

/*
 * Function to show logout alert section
 */
- (IBAction)logoutAction:(id)sender {
    alert = [[SCLAlertView alloc] init];
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SlideOutFromCenter;
    alert.hideAnimationType = SlideOutToCenter;
    SCLButton *logoutButton = [alert addButton:confirm actionBlock:^{
        [[accountManager.linkedAccounts objectAtIndex:0] unlink];
        [self.fileSystem removeObserver:self];
        self.account = nil;
        self.fileSystem = nil;
    }];
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
        DBFileInfo *info = ((NoteData *)[notesArray objectAtIndex:deleteIndex]).dbFileInfo;
        if ([self.fileSystem deletePath:info.path error:nil]) {
            [self.tableView setEditing:NO animated:YES];
        }
        else {
            
        }
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
    isCreate = false;
    clickIndex = [indexPath row];
    [self _presentWithSegueIdentifier:showCreateEditStr animated:NO];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = (!notesArray) ? 0 : [notesArray count];
    if(count == 0){
        [self showNoNoteTextLabel];
    } else {
        [self hideNoNoteTextLabel];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!notesArray) {
        return nil;
    }
    NSUInteger colorIndex = (NSUInteger)indexPath.row;
    if( colorIndex > [colors count] ) {
        colorIndex = colorIndex - [colors count];
    }
    NoteViewCell *cell;
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:NoteViewCellStr owner:self options:nil];
    cell = [nib objectAtIndex:0];
    NoteData *data = [notesArray objectAtIndex:[indexPath row]];
    cell.notesData.text = data.noteDesc;
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
            deleteIndex = [indexPath row];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    CreateEditViewController *vc = [segue destinationViewController];
    DBFileInfo *dbFileInfo = nil;
    if(!isCreate) {
        NoteData * nd = (NoteData *)[notesArray objectAtIndex:clickIndex];
        vc.dataTextStr = nd.noteDesc;
        dbFileInfo = nd.dbFileInfo;
    }
    else {
        vc.dataTextStr = emptyStr;
    }
    vc.isCreate = isCreate;
    vc.dbFileInfo = dbFileInfo;
    vc.fileSystem = self.fileSystem;
    vc.rootPath = self.root;
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
}


#pragma mark - Dropbox Functions

-(void) getDropboxAccount {
    
    accountManager= [[DBAccountManager alloc] initWithAppKey:@"udg615mw45s5izb" secret:@"lggw7vjvrqmsq7h"]; //Identifies the application
    [DBAccountManager setSharedManager:accountManager];
    self.account = [accountManager.linkedAccounts objectAtIndex:0];
    __weak ViewController *weakSelf = self;
    [accountManager addObserver:self block: ^(DBAccount *acc) {
        [weakSelf accountUpdated:acc];
    }];
}

-(void) accountUpdated : (DBAccount *) account {
    if (account.linked) {
        [self hideLoginScreen];
    }
    else if(!account.linked) {
        [notesArray removeAllObjects];
        [self reloadData];
        [self showLoginScreen];
    }
}

-(void) dropBoxInit {
    if( self.account ) {
        if(!self.fileSystem) {
            self.fileSystem = [[DBFilesystem alloc] initWithAccount:self.account];
        }
        if(!self.root) {
            self.root = [DBPath root];
        }
        __weak ViewController *vc = self;
        [self.fileSystem addObserver:self block:^() {
            if(isSyncing) {
                return;
            }
            [vc showSyncStatus];
            [vc reloadData];
        }];
        [self.fileSystem addObserver:self forPathAndChildren:self.root block:^() {
            if(isSyncing) {
                return;
            }
            [vc loadFiles];
        }];
        [self loadFiles];
    }
}

-(void) reloadData {
    [self.tableView reloadData];
    [self hideSyncStatus];
    isSyncing = false;
}

#pragma mark - private methods

NSInteger sortFileInfos(id obj1, id obj2, void *ctx) {
    DBFileInfo *file1 = (DBFileInfo *) obj1;
    DBFileInfo *file2 = (DBFileInfo *) obj2;
    return [[file1.path name] compare:[file2.path name]];
}

- (void)loadFiles {
    if(isSyncing) {
        return;
    }
    isSyncing = true;
    [self showSyncStatus];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        NSArray *immContents = [self.fileSystem listFolder:self.root error:nil];
        NSMutableArray *mContents = [NSMutableArray arrayWithArray:immContents];
        [mContents sortUsingFunction:sortFileInfos context:NULL];
        [self loadFileData:mContents];
    });
}


-(void) loadFileData : (NSMutableArray *) mContents {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        for (id object in mContents)
        {
            NoteData *data = [[NoteData  alloc] init];
            DBFileInfo *info = object;
            NSError *error = nil;
            DBFile *file = [self.fileSystem openFile:info.path error:&error];
            if (file) {
              NSString *str= [file readString:nil];
              data.noteDesc = str;
                if([str isEqual:emptyStr]) {
                    isSyncing = false;
                    break;
                }
            }
            else {
                data.noteDesc = [[error userInfo]description];
            }
            data.dbFileInfo = info;
            [tempArray addObject:data];
            [file close];
            [NSThread sleepForTimeInterval:0.1];
        }
        dispatch_async(dispatch_get_main_queue(), ^() {
            if(isSyncing) {
                notesArray = tempArray;
                [self reloadData];
            }
        });
    });
}

#pragma  mark - No Note Label functions

-(void) showNoNoteTextLabel {
    if(noNoteTextLbl)
    {
        return;
    }
    noNoteTextLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 220 , 40)];
    noNoteTextLbl.font = [UIFont fontWithName:fontName size:fontSize];
    noNoteTextLbl.text = noNoteLabel;
    noNoteTextLbl.textAlignment = NSTextAlignmentCenter;
    noNoteTextLbl.center = CGPointMake(SCREEN_CENTER_X, SCREEN_CENTER_Y);
    [self.view addSubview:noNoteTextLbl];
}

-(void) hideNoNoteTextLabel {
    if(!noNoteTextLbl) {
        return;
    }
    [noNoteTextLbl removeFromSuperview];
    noNoteTextLbl = nil;
}
@end
