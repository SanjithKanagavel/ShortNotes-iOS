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
    [self styleView];
}

-(void) styleView {
    self.noteBackgroundView.layer.cornerRadius = 30.0f;
    self.noteBackgroundView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.noteBackgroundView.layer.borderWidth = 1.5f;
    self.noteBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.noteBackgroundView.layer.shadowOpacity = 0.8;
    self.noteBackgroundView.layer.shadowRadius = 3.0;
    self.noteBackgroundView.layer.shadowOffset = CGSizeMake(2.0, 2.0);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:self.noteBackgroundView.frame];
    selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    [self setSelectedBackgroundView:selectedBackgroundView];
}

-(void) setViewColour : (UIColor *) color{
    self.noteBackgroundView.backgroundColor = color;
}

@end
