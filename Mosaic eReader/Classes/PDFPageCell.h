//
//  PDFViewCell.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 2/3/11.
//  Copyright 2011 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDFPageView.h"
#import <UIKit/UIKit.h>

@interface PDFPageCell : UITableViewCell 
{
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *messageLabel;
	IBOutlet UIImageView *pdfView; 
}

@property (nonatomic,retain) IBOutlet UILabel *nameLabel;
@property (nonatomic,retain) IBOutlet UILabel *messageLabel;
@property (nonatomic,retain) IBOutlet UIImageView *pdfView;

@end
