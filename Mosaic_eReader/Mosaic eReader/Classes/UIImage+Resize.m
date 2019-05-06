//
//  UIImage+Resize.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 3/1/11.
//  Copyright 2011 . All rights reserved.
//

#import "UIImage+Resize.h"


@implementation UIImage (Resize)

- (UIImage *)imageScaledToSize: (CGSize)size 
{
	UIGraphicsBeginImageContext(size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0, size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), self.CGImage);
	
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	
    // [scaledImage autorelease];
    
	UIGraphicsEndImageContext();
	
	return scaledImage;
}

@end
