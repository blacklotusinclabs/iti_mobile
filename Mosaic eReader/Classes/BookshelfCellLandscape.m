//
//  BookshelfCellLandscape.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookshelfCellLandscape.h"
#import "BookshelfViewController.h"

@implementation BookshelfCellLandscape

@synthesize bookImage1;
@synthesize bookImage2;
@synthesize bookImage3;
@synthesize bookImage4;
@synthesize label1;
@synthesize label2;
@synthesize label3;
@synthesize label4;
@synthesize shadow1;
@synthesize shadow2;
@synthesize shadow3;
@synthesize shadow4;
@synthesize books;
@synthesize labels;
@synthesize shadows;
@synthesize viewController;

@synthesize bookImage5;
@synthesize bookImage6;
@synthesize shadow5;
@synthesize shadow6;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) != nil) {
        /*
		books = [[NSMutableArray alloc] init];
		labels = [[NSMutableArray alloc] init];
		
		[books addObject: bookImage1];
		[books addObject: bookImage2];
		[books addObject: bookImage3];
		[books addObject: bookImage4];
        
		[labels addObject: label1];
		[labels addObject: label2];
		[labels addObject: label3];
		[labels addObject: label4];
        
        [books addObject: bookImage4];
		[labels addObject: label4];
         */
    }
    return self;
}

- (void) awakeFromNib
{
    /*
	books = [[NSMutableArray alloc] init];
	labels = [[NSMutableArray alloc] init];
	shadows = [[NSMutableArray alloc] init];
	
	[books addObject: bookImage1];
	[books addObject: bookImage2];
	[books addObject: bookImage3];
	[books addObject: bookImage4];
	[books addObject: bookImage5];
    [books addObject: bookImage6];
    
	//[labels addObject: label1];
	//[labels addObject: label2];
	//[labels addObject: label3];
	//[labels addObject: label4];	
    
	[shadows addObject: shadow1];
	[shadows addObject: shadow2];
	[shadows addObject: shadow3];
	[shadows addObject: shadow4];	
    [shadows addObject: shadow5];
    [shadows addObject: shadow6];
     */
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    // [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

- (IBAction) selectBook: (id)sender
{
	[(BookshelfViewController *)viewController selectBookWithTag: [sender tag]];
}

@end
