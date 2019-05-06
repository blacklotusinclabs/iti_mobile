//
//  CustomCell.h
//  TrollbeadsLocator
//
//  Created by Gregory Casamento on 4/28/10.
//  Copyright 2010 Open Logic Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomCell : UITableViewCell 
{
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *messageLabel;
	IBOutlet UIImageView *imageView;
}

@property (nonatomic,retain) IBOutlet UILabel *nameLabel;
@property (nonatomic,retain) IBOutlet UILabel *messageLabel;
@property (nonatomic,retain) IBOutlet UIImageView *imageView;

@end
