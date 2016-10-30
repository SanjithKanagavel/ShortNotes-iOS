//
//  NoteData.h
//  ShortNotes
//
//  Created by Sanjith Kanagavel on 27/10/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "Foundation/Foundation.h"
#import "Dropbox/Dropbox.h"

@interface NoteData : NSObject
    @property(strong,nonatomic) NSString *noteDesc;
    @property(strong,nonatomic) DBFileInfo *dbFileInfo;
@end

