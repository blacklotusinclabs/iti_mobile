//
//  BookshelfCell.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 11/9/10.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BookshelfCell : UITableViewCell
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

- (IBAction) selectBook: (id)sender;

@end
