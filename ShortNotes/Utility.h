//
//  Utility.h
//  ShortNotes
//
//  Created by Sanjith Kanagavel on 29/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "Foundation/Foundation.h"
#import "UIKit/UIKit.h"
#import "SCLAlertView.h"
#import "Constants.h"

@interface Utility : NSObject
    @property(weak,nonatomic) SCLAlertView *alert;
    + (UIColor *) colorFromHexString:(NSString *)hexString;
    + (void) styleNaviBar;
    + (void) showCustomAlert:(UIViewController *)controller image:(UIImage *)image title:(NSString *)title subTitle:(NSString *)subTitle;
    + (void) showConfirmAlert:(UIViewController *)controller image:(UIImage *)image title:(NSString *)title subTitle:(NSString *)subTitle confirmAction:(SCLActionBlock)confirmAction cancelAction:(SCLActionBlock)cancelAction;
@end
