//
//  BookshelfCellLandscape.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookshelfCell.h"

@interface BookshelfCellLandscape : UITableViewCell
{
    IBOutlet UIButton *bookImage1;
	IBOutlet UIButton *bookImage2;
	IBOutlet UIButton *bookImage3;
	IBOutlet UIButton *bookImage4;
	IBOutlet UILabel *label1;
	IBOutlet UILabel *label2;
	IBOutlet UILabel *label3;
	IBOutlet UILabel *label4;
	IBOutlet UIImageView *shadow1;
	IBOutlet UIImageView *shadow2;
	IBOutlet UIImageView *shadow3;
	IBOutlet UIImageView *shadow4;
	UIViewController *viewController;
	NSMutableArray *books;
	NSMutableArray *labels;
	NSMutableArray *shadows;
    
    IBOutlet UIButton *bookImage5;
    IBOutlet UIButton *bookImage6;
	IBOutlet UIImageView *shadow5;
	IBOutlet UIImageView *shadow6;
}

@property (nonatomic,assign) UIButton *bookImage1;
@property (nonatomic,assign) UIButton *bookImage2;
@property (nonatomic,assign) UIButton *bookImage3;
@property (nonatomic,assign) UIButton *bookImage4;
@property (nonatomic,assign) UILabel *label1;
@property (nonatomic,assign) UILabel *label2;
@property (nonatomic,assign) UILabel *label3;
@property (nonatomic,assign) UILabel *label4;
@property (nonatomic,assign) UIImageView *shadow1;
@property (nonatomic,assign) UIImageView *shadow2;
@property (nonatomic,assign) UIImageView *shadow3;
@property (nonatomic,assign) UIImageView *shadow4;

@property (nonatomic,readonly) NSMutableArray *books;
@property (nonatomic,readonly) NSMutableArray *labels;
@property (nonatomic,readonly) NSMutableArray *shadows;

@property (nonatomic,assign) UIViewController *viewController;

@property (nonatomic,assign) UIButton *bookImage5;
@property (nonatomic,assign) UIButton *bookImage6;
@property (nonatomic,assign) UIImageView *shadow5;
@property (nonatomic,assign) UIImageView *shadow6;

- (IBAction) selectBook: (id)sender;

@end
