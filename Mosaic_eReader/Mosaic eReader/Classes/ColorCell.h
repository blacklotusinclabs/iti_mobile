//
//  ColorCell.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ColorCell : UITableViewCell {
    IBOutlet UIImageView *colorView;
    IBOutlet UILabel *colorName;
}

@property (nonatomic, assign) UIImageView *colorView;
@property (nonatomic, assign) UILabel *colorName;

@end
