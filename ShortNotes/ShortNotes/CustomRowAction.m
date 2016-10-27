//
//  CustomRowAction.m
//  ShortNotes
//
//  Created by Sanjith Kanagavel on 26/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "CustomRowAction.h"
#import "Constants.h"

@implementation CustomRowAction

+ (instancetype)rowActionWithStyle:(UITableViewRowActionStyle)style title:(NSString *)title icon:(UIImage*)icon handler:(void (^)(UITableViewRowAction *action, NSIndexPath *indexPath))handler
{
    title = [newLine stringByAppendingString:title];
    CustomRowAction *action = [super rowActionWithStyle:style title:title handler:handler];
    action.actionImage = icon;
    return action;
}

- (void)_setButton:(UIButton*)button
{
    
    UIImage *orgImg=[self.actionImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *resizedImg = [self imageResize:orgImg scaledToSize:CGSizeMake(orgImg.size.width/3, orgImg.size.height/3)];
    [button setImage:resizedImg forState:UIControlStateNormal];
    [button setImage:resizedImg forState:UIControlStateHighlighted];
    [button setImage:resizedImg forState:UIControlStateSelected];
    button.tintColor = button.titleLabel.textColor;
    button.titleLabel.font = [UIFont fontWithName:fontName size:20.0];
    CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}];
    button.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height/2 + 5), 0, 0, -titleSize.width);
    
}

- (UIImage *)imageResize:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [[UIColor whiteColor] set];
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
