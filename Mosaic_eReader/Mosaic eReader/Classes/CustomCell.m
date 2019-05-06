//
//  CustomCell.m
//  TrollbeadsLocator
//
//  Created by Gregory Casamento on 4/28/10.
//  Copyright 2010 Open Logic Corporation. All rights reserved.
//

#import "CustomCell.h"


@implementation CustomCell

@synthesize nameLabel;
@synthesize messageLabel;
@synthesize imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) != nil) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
