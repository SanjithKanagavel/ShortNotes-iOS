//
//  CreateEditViewController.h
//  ShortNotes
//
//  Created by Sanjith Kanagavel on 26/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dropbox/Dropbox.h"

@interface CreateEditViewController : UIViewController<UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UITextView *dataText;
@property BOOL isCreate;
@property NSString* dataTextStr;
@property DBFileInfo *dbFileInfo;
@property DBFilesystem *fileSystem;
@property DBPath *rootPath;
@end
