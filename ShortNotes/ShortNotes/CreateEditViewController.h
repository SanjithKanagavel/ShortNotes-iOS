//
//  CreateEditViewController.h
//  ShortNotes
//
//  Created by Sanjith Kanagavel on 26/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateEditViewController : UIViewController<UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UITextView *dataText;

@end
