//
//  BookshelfCell.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 11/9/10.
//  Copyright 2010 . All rights reserved.
//

#import "BookshelfCell.h"
#import "BookshelfViewController.h"

@implementation BookshelfCell

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

/*
- (id) initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder: aDecoder]) != nil)
    {
        books = [[NSMutableArray alloc] init];
        labels = [[NSMutableArray alloc] init];
        shadows = [[NSMutableArray alloc] init];
        
        [books addObject: bookImage1];
        [books addObject: bookImage2];
        [books addObject: bookImage3];
        [books addObject: bookImage4];
        
        [shadows addObject: shadow1];
        [shadows addObject: shadow2];
        [shadows addObject: shadow3];
        [shadows addObject: shadow4];	    
    }
    return self;
}
*/

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) != nil) {
        /*
        books = [[NSMutableArray alloc] init];
        labels = [[NSMutableArray alloc] init];
        shadows = [[NSMutableArray alloc] init];
		
		[books addObject: bookImage1];
		[books addObject: bookImage2];
		[books addObject: bookImage3];
		[books addObject: bookImage4];
        
		// [labels addObject: label1];
		// [labels addObject: label2];
		// [labels addObject: label3];
		// [labels addObject: label4];
                
        [shadows addObject: shadow1];
        [shadows addObject: shadow2];
        [shadows addObject: shadow3];
        [shadows addObject: shadow4];
         */
    }
    return self;
}

- (void) awakeFromNib
{
    /*
    if(books == nil)
    {
        books = [[NSMutableArray alloc] init];
        labels = [[NSMutableArray alloc] init];
        shadows = [[NSMutableArray alloc] init];
        
        [books addObject: bookImage1];
        [books addObject: bookImage2];
        [books addObject: bookImage3];
        [books addObject: bookImage4];
        
        [shadows addObject: shadow1];
        [shadows addObject: shadow2];
        [shadows addObject: shadow3];
        [shadows addObject: shadow4];	
    }
     */
}

- (void) dealloc
{
    [books release];
    [labels release];
    [shadows release];
    [super dealloc];
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