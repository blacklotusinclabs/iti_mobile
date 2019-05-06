//
//  UIView+Image.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 3/16/11.
//  Copyright 2011 . All rights reserved.
//

#import "UIView+Image.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView

- (UIImage *) image
{
	UIGraphicsBeginImageContext(self.bounds.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return viewImage;
}

@end
