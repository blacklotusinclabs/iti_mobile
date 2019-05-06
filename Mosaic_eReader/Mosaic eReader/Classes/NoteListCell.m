//
//  NoteListCell.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteListCell.h"


@implementation NoteListCell

@synthesize noteImage;
@synthesize noteLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [super dealloc];
}

@end
