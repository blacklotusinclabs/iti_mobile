//
//  PDFViewCell.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 2/3/11.
//  Copyright 2011 . All rights reserved.
//

#import "PDFPageCell.h"


@implementation PDFPageCell
@synthesize nameLabel;
@synthesize messageLabel;
@synthesize pdfView;

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
