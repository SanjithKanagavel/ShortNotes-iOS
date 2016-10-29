//
//  Utility.m
//  ShortNotes
//
//  Created by Sanjith Kanagavel on 29/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "Utility.h"


@implementation Utility

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (void) styleNaviBar {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:naviTxt] forBarMetrics:UIBarMetricsDefault];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:fontName size:21.0], NSFontAttributeName, nil]];
    
}

+ (void) showCustomAlert:(UIViewController *)controller image:(UIImage *)image title:(NSString *)title subTitle:(NSString *)subTitle{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SlideOutFromCenter;
    alert.hideAnimationType = SlideOutToCenter;
    [alert showCustom:controller image:image color:[self colorFromHexString:alertColor] title:title subTitle:subTitle closeButtonTitle:nil duration:0.0f];
}

+ (void) showConfirmAlert:(UIViewController *)controller image:(UIImage *)image title:(NSString *)title subTitle:(NSString *)subTitle confirmAction:(SCLActionBlock)confirmAction cancelAction:(SCLActionBlock)cancelAction {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SlideOutFromCenter;
    alert.hideAnimationType = SlideOutToCenter;
    SCLButton *logoutButton = [alert addButton:confirm actionBlock:confirmAction];
    SCLButton *cancelButton = [alert addButton:cancel actionBlock:cancelAction];
    ButtonFormatBlock buttonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[cornerRadiusStr] = logoutBtnCR;
        return buttonConfig;
    };
    logoutButton.buttonFormatBlock = buttonFormatBlock;
    cancelButton.buttonFormatBlock = buttonFormatBlock;
    [alert showCustom:controller image:image color:[self colorFromHexString:alertColor] title:title subTitle:subTitle closeButtonTitle:nil duration:0.0f];
}


@end
