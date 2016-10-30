//
//  CustomRowAction.h
//  ShortNotes
//
//  Created by Sanjith Kanagavel on 26/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomRowAction : UITableViewRowAction
    @property(strong,nonatomic) UIImage *actionImage;
    @property(strong,nonatomic) UIFont *font;
    + (instancetype)rowActionWithStyle:(UITableViewRowActionStyle)style title:(NSString *)title icon:(UIImage*)icon handler:(void (^)(UITableViewRowAction *action, NSIndexPath *indexPath))handler;
@end
