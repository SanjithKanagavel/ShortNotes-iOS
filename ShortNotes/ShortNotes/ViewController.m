//
//  ViewController.m
//  ShortNotes
//
//  Created by Sanjith Kanagavel on 25/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

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
    [self getDropboxAccount];
}

/*
 * Function that intializes dropbox after view appear
 */
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(!viewDataRequested) {
        viewDataRequested = true;
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
    if(self.syncStatusView == nil) {
     self.syncStatusView = [[UIView alloc]initWithFrame:CGRectMake(0,self.naviBar.frame.size.height, SCREEN_CENTER_X*2, 30)];
    }
    else {
        return; //Sync view is already in progress
    }
    [self.syncStatusView setBackgroundColor:[Utility colorFromHexString:orangeColor1]];
    UILabel *syncLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.syncStatusView.frame.size.width, self.syncStatusView.frame.size.height)];
    syncLable.center = CGPointMake(self.syncStatusView.frame.size.width/2, self.syncStatusView.frame.size.height/2);
    syncLable.textAlignment  = NSTextAlignmentCenter;
    syncLable.text = syncInProgress;
    syncLable.textColor = [Utility colorFromHexString:whiteColor];
    syncLable.font = [UIFont fontWithName:fontName size:20.0];
    self.syncStatusView.alpha = 0.8;
    [self.syncStatusView addSubview:syncLable];
    [self.view insertSubview:self.syncStatusView atIndex:1];
}

/*
 * Function to hide SyncStatusBar
 */
-(void) hideSyncStatus {
    if(!self.syncStatusView) {
        return;
    }
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.syncStatusView setFrame:CGRectMake(self.syncStatusView.frame.origin.x, self.syncStatusView.frame.origin.y-30, self.syncStatusView.frame.size.width,self.syncStatusView.frame.size.height )];
    } completion:^(BOOL finished){
        [self.syncStatusView removeFromSuperview];
        self.syncStatusView = nil;
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
    if(self.loginView) {
        return ;
    }
    self.loginView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,self.view.frame.size.width, self.view.frame.size.height)];
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.loginView.bounds;
    UIImageView *loginImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconImg]];
    [loginImage setFrame:CGRectMake(0, 0, 100, 100)];
    [loginImage setCenter:CGPointMake(SCREEN_CENTER_X,SCREEN_CENTER_Y)];
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setBackgroundImage:[UIImage imageNamed:loginBtn] forState:UIControlStateNormal];
    loginButton.frame = CGRectMake(0, 0, 210, 55);
    [loginButton setCenter:CGPointMake(SCREEN_CENTER_X,(SCREEN_CENTER_Y*2)-100)];
    [loginButton addTarget:self action:@selector(loginDropBox) forControlEvents:UIControlEventTouchUpInside];
    [self.loginView addSubview:visualEffectView];
    [self.loginView addSubview:loginImage];
    [self.loginView addSubview:loginButton];
    self.loginView.alpha = 1;
    [self.view addSubview:self.loginView];
    
}

/*
 * Function to hide Login Screen
 */
-(void) hideLoginScreen {
    if(!self.loginView) {
        return;
    }
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.loginView.alpha = 0;
        [self.loginView removeFromSuperview];
        self.loginView = nil;
    } completion:nil];
}

/*
 * Function for setting local variables required
 */
-(void) initLocalVariables {
    SCREEN_CENTER_X=[[UIScreen mainScreen]bounds].size.width/2;
    SCREEN_CENTER_Y=[[UIScreen mainScreen]bounds].size.height/2;
    colors = @[ peterRiver,belizeHole,amethyst,wisteria,sunFlower,
                orange,carrot,pumpkin,alizarin,pomegranate,turquoise, greenSea,emerald,nephritis,concrete,asbestos,wetAsphalt,midnightBlue ];
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
            [self.fileSystem removeObserver:self];
            [[self.accountManager.linkedAccounts objectAtIndex:0] unlink];
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
    if( colorIndex > [colors count] - 1 ) {
        colorIndex = colorIndex % [colors count];
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
        [self.fileSystem addObserver:self forPathAndChildren:self.root block:^() {
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
    isSyncing = false;
    [self hideSyncStatus];
    [self showNoNoteTextLabel];
}

#pragma mark - private methods

/*
 * Function to sort notes for viewing
 */
NSInteger sortFileInfos(id obj1, id obj2, void *ctx) {
    DBFileInfo *file1 = (DBFileInfo *) obj1;
    DBFileInfo *file2 = (DBFileInfo *) obj2;
    NSInteger val = [[file1.path name] compare:[file2.path name]];
    return ( val < 0 ) ? 1: -1;
}

/*
 * Function to sync notes. Retrieve files from dropbox
 */
- (void)loadFiles {
    if(isSyncing) {
        return;
    }
    isSyncing = true;
    [self showNoNoteTextLabel];
    [self showSyncStatus];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
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
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        for (id object in mContents)
        {
            NoteData *data = [[NoteData  alloc] init];
            DBFileInfo *info = object;
            data.dbFileInfo = object;
            NSError *error = nil;
            DBFile *file = [self.fileSystem openFile:info.path error:&error];
            if (file) {
              NSString *str= [file readString:nil];
              data.noteDesc = str;
              if([str isEqual:emptyStr]) {
                  isSyncing = false;
                  [self showNoNoteTextLabel];
                  break;
              }
            }
            else {
                data.noteDesc = [[error userInfo]description];
                dispatch_async(dispatch_get_main_queue(), ^() {
                    [Utility showCustomAlert:self image:[UIImage imageNamed:infoButtonLStr] title:dataerrorTitle subTitle:dataerrorSubtitle];
                });                
            }            
            [tempArray addObject:data];
            [file close];
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if(isSyncing) {
                notesArray = tempArray;
                [self reloadData];
            }
        });
}

#pragma  mark - No Note Label functions

/*
 * Function to show "No Notes Available"
 */
-(void) showNoNoteTextLabel {    
    if([notesArray count] > 0 ) {
        [self hideSyncStatus];
        return;
    }
    if(self.noNoteTextLbl) {
        self.noNoteTextLbl.text = (isSyncing) ? loadingNotesLabel : noNoteLabel;
        return;
    }
    self.noNoteTextLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 220 , 40)];
    self.noNoteTextLbl.font = [UIFont fontWithName:fontName size:fontSize];
    self.noNoteTextLbl.text = (isSyncing) ? loadingNotesLabel : noNoteLabel;
    self.noNoteTextLbl.textAlignment = NSTextAlignmentCenter;
    self.noNoteTextLbl.center = CGPointMake(SCREEN_CENTER_X, SCREEN_CENTER_Y);
    [self.view addSubview:self.noNoteTextLbl];
}

/*
 * Function to hide "No Notes Available"
 */
-(void) hideNoNoteTextLabel {
    if(!self.noNoteTextLbl) {
        return;
    }
    [self.noNoteTextLbl removeFromSuperview];
    self.noNoteTextLbl = nil;
}
@end
