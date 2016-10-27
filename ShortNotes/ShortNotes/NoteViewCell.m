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
    [self.noteBackgroundView.layer setCornerRadius:30.0f];
    [self.noteBackgroundView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.noteBackgroundView.layer setBorderWidth:1.5f];
    [self.noteBackgroundView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.noteBackgroundView.layer setShadowOpacity:0.8];
    [self.noteBackgroundView.layer setShadowRadius:3.0];
    [self.noteBackgroundView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:self.noteBackgroundView.frame];
    [selectedBackgroundView setBackgroundColor:[UIColor whiteColor]]; 
    [self setSelectedBackgroundView:selectedBackgroundView];
}

-(void) setViewColour : (UIColor *) color{
    [self.noteBackgroundView setBackgroundColor:color];
}

@end
