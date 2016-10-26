//
//  ViewController.h
//  ShortNotes
//
//  Created by Sanjith Kanagavel on 25/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *infoButton;
@end

