//
//  NoteListCell.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NoteListCell : UITableViewCell {
    IBOutlet UIImageView *noteImage;
    IBOutlet UILabel *noteLabel;
}

@property (nonatomic, assign) UIImageView *noteImage;
@property (nonatomic, assign) UILabel *noteLabel;

@end
