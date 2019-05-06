//
//  ColorCell.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ColorCell.h"


@implementation ColorCell

@synthesize colorView, colorName;

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
