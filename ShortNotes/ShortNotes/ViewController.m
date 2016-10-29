//
//  ViewController.m
//  ShortNotes
//
//  Created by Sanjith Kanagavel on 25/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

UIView *syncStatusView;
UIView *loginView;
UILabel *noNoteTextLbl;

NSArray *colors;
NSMutableArray *notesArray;
NSUInteger deleteIndex;
NSUInteger clickIndex;
BOOL isCreate;
BOOL viewDataRequested;
BOOL isSyncing;
double SCREEN_CENTER_X;
double SCREEN_CENTER_Y;

#pragma mark - View Functions

/*
 * Function loading login screen and base screen
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLocalVariables];
    [self configureBaseScreen];
}

/*
 * Function that intializes dropbox after view appear
 */
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(!viewDataRequested) {
        viewDataRequested = true;
        [self getDropboxAccount];
        if(!self.account) {
            [self showLoginScreen];
        }
        else {
            [self dropBoxAccountInit];
        }
    }
}

/*
 * Function that notifies after memory warning.
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


#pragma mark - Sync Status Functions

/*
 * Function to show SyncStatusBar
 */
-(void) showSyncStatus {
    UIView *c1,*c2,*c3;
    if(syncStatusView == nil) {
     syncStatusView = [[UIView alloc]initWithFrame:CGRectMake(0,self.naviBar.frame.size.height, SCREEN_CENTER_X*2, 30)];
    }
    else {
        return; //Sync view is already in progress
    }
    float statusCenterX = syncStatusView.frame.size.width/2;
    [syncStatusView setBackgroundColor:[Utility colorFromHexString:orangeColor1]];
    c1 = [[UIView alloc]initWithFrame:CGRectMake(statusCenterX-10,5,20,20)];
    c1.layer.cornerRadius=10;
    [c1 setBackgroundColor:[Utility colorFromHexString:orangeColor2]];
    c2 = [[UIView alloc]initWithFrame:CGRectMake(statusCenterX+30,5,20,20)];
    c2.layer.cornerRadius=10;
    [c2 setBackgroundColor:[Utility colorFromHexString:orangeColor2]];
    c3 = [[UIView alloc]initWithFrame:CGRectMake(statusCenterX-50,5,20,20)];
    c3.layer.cornerRadius=10;
    [c3 setBackgroundColor:[Utility colorFromHexString:orangeColor2]];
    c1.alpha = 0; c2.alpha = 0; c3.alpha = 0;
    [syncStatusView addSubview:c3]; [syncStatusView addSubview:c2]; [syncStatusView addSubview:c1];
    syncStatusView.alpha = 0.8;
    [self.view insertSubview:syncStatusView atIndex:1];
    [self syncStatusAnimation:c1 secondCircle:c2 thridCircle:c3];
}

/*
 * Function to animate SyncStatusBar
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
 * Function to hide SyncStatusBar
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
    [Utility styleNaviBar];
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
 * Function for setting local variables required
 */
-(void) initLocalVariables {
    SCREEN_CENTER_X=[[UIScreen mainScreen]bounds].size.width/2;
    SCREEN_CENTER_Y=[[UIScreen mainScreen]bounds].size.height/2;
    colors = @[ turquoise, greenSea,emerald,nephritis,peterRiver,belizeHole,amethyst,wisteria,sunFlower,
                orange,carrot,pumpkin,alizarin,pomegranate,concrete,asbestos,wetAsphalt,midnightBlue ];
    viewDataRequested  = false;
    isSyncing = false;
}



#pragma mark - Actions

/*
 * Function to create new note
 */
-(void) createNewNoteAction {
    isCreate = true;
    [self performSegueWithIdentifier:showCreateEditStr sender:nil];
}

/*
 * Function to show info alert section
 */
- (IBAction)infoAction:(id)sender {
    [Utility showCustomAlert:self image:[UIImage imageNamed:infoButtonLStr] title:infoTitle subTitle:infoSubtitle];
}

/*
 * Function to login Dropbox
 */
- (void) loginDropBox {
    if(self.account) {
        [self hideLoginScreen];
        return;
    }
    [self.accountManager linkFromController:self];
}

/*
 * Function to logout Dropbox
 */
- (IBAction)logoutAction:(id)sender {
    [Utility showConfirmAlert:self image:[UIImage imageNamed:logoutButtonLStr] title:logoutTitle subTitle:nil confirmAction:^{
            [[self.accountManager.linkedAccounts objectAtIndex:0] unlink];
            [self.fileSystem removeObserver:self];
            self.account = nil;
            self.fileSystem = nil;
        } cancelAction:^{}
     ];
}

/*
 * Function to delete a note 
 */
-(void) deleteTaskAction {
    [Utility showConfirmAlert:self image:[UIImage imageNamed:deleteBtn] title:confirmDelete subTitle:nil confirmAction:^{
            DBFileInfo *info = ((NoteData *)[notesArray objectAtIndex:deleteIndex]).dbFileInfo;
            if ([self.fileSystem deletePath:info.path error:nil]) {
                [self.tableView setEditing:NO animated:YES];
            }
            else {
                [Utility showCustomAlert:self image:[UIImage imageNamed:infoButtonLStr] title:datadeleteTitle subTitle:datadeleteSubtitle];
            }
        } cancelAction:^{}
    ];
}

#pragma mark - UITableView Functions

/*
 * Function to show note when clicked on a row
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    isCreate = false;
    clickIndex = [indexPath row];
    [self performSegueWithIdentifier:showCreateEditStr sender:nil];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

/*
 * Function to show number of section
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/*
 * Function to show number of rows
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = (!notesArray) ? 0 : [notesArray count];
    if(count == 0){
        [self showNoNoteTextLabel];
    } else {
        [self hideNoNoteTextLabel];
    }
    return count;
}

/*
 * Function to Load Custom Cell
 */
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
    [cell setViewColour:[Utility colorFromHexString:colors[colorIndex]]];
    colorIndex++;
    return cell;
}

/*
 * Function that allows show row actions
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

/*
 * Function to show custom row actions
 */
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    CustomRowAction *add = [CustomRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:deleteStr icon:[UIImage imageNamed:deleteBtn] handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            [self deleteTaskAction];
            deleteIndex = [indexPath row];
    }];
    add.backgroundColor = UIColor.orangeColor;
    return @[add];
}

/*
 * Function to set height of Custom Cell
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}



#pragma mark - Navigation

/*
 * Function to prepare segue with actions before navigating
 */
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

#pragma mark - Dropbox Functions

/*
 * Function to configure account manager,account and set its observer
 */
-(void) getDropboxAccount {
    self.accountManager= [[DBAccountManager alloc] initWithAppKey:apiKey secret:apiSecret];
    [DBAccountManager setSharedManager:self.accountManager];
    self.account = [self.accountManager.linkedAccounts objectAtIndex:0];
    __weak ViewController *weakSelf = self;
    [self.accountManager addObserver:self block: ^(DBAccount *acc) {
        [weakSelf accountUpdated:acc];
    }];
}

/*
 * Function that observers whenever user account manager changes
 */
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

/*
 * Function that configure dropbox account
 */
-(void) dropBoxAccountInit {
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

/*
 * Function that reloads tableview whenever contents changes
 */
-(void) reloadData {
    [self.tableView reloadData];
    [self hideSyncStatus];
    isSyncing = false;
}

#pragma mark - private methods

/*
 * Function to sort notes for viewing
 */
NSInteger sortFileInfos(id obj1, id obj2, void *ctx) {
    DBFileInfo *file1 = (DBFileInfo *) obj1;
    DBFileInfo *file2 = (DBFileInfo *) obj2;
    return [[file1.path name] compare:[file2.path name]];
}

/*
 * Function to sync notes. Retrieve files from dropbox
 */
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

/*
 * Function to sync notes. Retrieve file data from dropbox
 */
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
                [Utility showCustomAlert:self image:[UIImage imageNamed:infoButtonLStr] title:dataerrorTitle subTitle:dataerrorSubtitle];
                
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

/*
 * Function to show "No Notes Available"
 */
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

/*
 * Function to hide "No Notes Available"
 */
-(void) hideNoNoteTextLabel {
    if(!noNoteTextLbl) {
        return;
    }
    [noNoteTextLbl removeFromSuperview];
    noNoteTextLbl = nil;
}
@end
