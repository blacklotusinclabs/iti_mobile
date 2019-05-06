//
//  PDFPageView.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 2/3/11.
//  Copyright 2011 . All rights reserved.
//

#import "PDFPageView.h"


@implementation PDFPageView

- (void) dealloc
{
    CGPDFDocumentRelease(document);
    [super dealloc];
}

- (void) setDocumentRef: (CGPDFDocumentRef)doc
		   pageNumber: (NSUInteger)page;
{
	document = doc;
    CGPDFDocumentRetain(document);
	myPageRef = CGPDFDocumentGetPage(document, (size_t)page);		
	[self setNeedsDisplay];
	[self.layer setNeedsDisplay];
	[self.layer setNeedsLayout];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	CGRect rect = [self frame];
	CGPDFPageRef pageRef = myPageRef;
	if (pageRef != nil && ctx != nil) {
		[(NSObject*)pageRef retain];
		
		// PDF might be transparent, assume white paper
		[[UIColor whiteColor] set];
		CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);		
		CGContextFillRect(ctx, CGContextGetClipBoundingBox(ctx));		
		CGContextFillRect(ctx, rect);
		
		// Flip coordinates
		CGContextGetCTM(ctx);
		CGContextScaleCTM(ctx, 1, -1);
		CGContextTranslateCTM(ctx, 0, -rect.size.height);
		
		// get the rectangle of the cropped inside
		CGRect mediaRect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
		CGContextScaleCTM(ctx, rect.size.width / mediaRect.size.width,
						  rect.size.height / mediaRect.size.height);
		CGContextTranslateCTM(ctx, -mediaRect.origin.x, -mediaRect.origin.y);
		
		// draw it
		CGContextDrawPDFPage(ctx, pageRef);		
		[(NSObject *)pageRef release];
	}
	
}

@end
