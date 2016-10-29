//
//  CreateEditViewController.h
//  ShortNotes
//
//  Created by Sanjith Kanagavel on 26/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "UIKit/UIKit.h"
#import "Dropbox/Dropbox.h"
#import "Constants.h"
#import "SCLAlertView.h"
#import "Utility.h"

@interface CreateEditViewController : UIViewController<UITextViewDelegate>
    @property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
    @property (strong, nonatomic) IBOutlet UITextView *dataText;
    @property (weak, nonatomic) NSString* dataTextStr;
    @property (weak, nonatomic) DBFileInfo *dbFileInfo;
    @property (weak, nonatomic) DBFilesystem *fileSystem;
    @property (weak, nonatomic) DBPath *rootPath;
    @property BOOL isCreate;
@end
