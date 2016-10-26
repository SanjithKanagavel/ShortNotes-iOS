//
//  NoteViewCell.m
//  ShortNotes
//
//  Created by Sanjith Kanagavel on 25/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "NoteViewCell.h"
#import "Constants.h"

@implementation NoteViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.noteBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:cellTexture]]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
