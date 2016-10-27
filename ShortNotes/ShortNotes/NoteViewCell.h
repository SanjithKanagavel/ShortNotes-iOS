//
//  NoteViewCell.h
//  ShortNotes
//
//  Created by Sanjith Kanagavel on 25/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *noteBackgroundView;
@property (strong, nonatomic) IBOutlet UILabel *notesData;
-(void) setViewColour : (UIColor *) color;
@end
