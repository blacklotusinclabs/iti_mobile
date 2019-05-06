//
//  PDFView.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 11/3/10.
//  Copyright 2010 . All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#import "PDFView.h"
#import "PublicationViewController.h"
#import "MLDataStore.h"

#import "Scanner.h"

@implementation PDFView

@synthesize pubController, numPages, book, searchTerm;

- (void) _forwardSwipe: (UISwipeGestureRecognizer *)sender
{
	if(currentPage == numPages)
	{
		return;
	}
	
	currentPage++;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];

	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp 
						   forView:self cache:YES];
	// [player play];
	
	// set view properties
	[UIView commitAnimations];	
	[self goToPage: currentPage];
}

- (void) _backwardSwipe: (UISwipeGestureRecognizer *)sender
{
	if(currentPage == 1)
	{
		return;
	}
	
	currentPage--;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];

	[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown
						   forView:self cache:YES];

	// [player play];
	
	// set view properties
	[UIView commitAnimations];		
	[self goToPage: currentPage];
}

- (void) _tapGesture: (UITapGestureRecognizer *)sender
{
	[pubController toggleToolbars];
}

- (void) awakeFromNib
{
    /*
	NSURL *fileUrl = [[NSBundle mainBundle] URLForResource: @"pageflip" withExtension: @"wav"];
	player = [[AVAudioPlayer alloc] initWithContentsOfURL: fileUrl error: NULL];
     */
    dataStore = [MLDataStore sharedInstance];
}

- (void) goToPage: (NSUInteger)pageNum
{
	if(pageNum < 1)
	{
		pageNum = 1;
	}
	
	if(pageNum > numPages)
	{
		pageNum = 1;
	}
	
    if([dataStore dataExistsForPage: pageNum withBookId: pubController.publication.bookId] == NO)
    {
        //  [pubController stopPageCachingThread];
        NSLog(@"Data does not exist for page, fetching...");
    }
    
	currentPage = pageNum;
   	[self setNeedsDisplay];	
    [self.layer setNeedsDisplay];
    [self.layer setNeedsLayout];    
	[pubController setSliderValue: pageNum];
}

- (NSArray *) selectionsForPage: (CGPDFPageRef)pageRef
{
    Scanner *scanner = [[Scanner alloc] init];
    scanner.keyword = searchTerm;
    [scanner scanPage: pageRef];
    NSArray *selections = scanner.selections;
    return selections;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	CGRect rect = [self frame];
    NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];    
    NSData *pageData = [dataStore imageForBookId: pubController.publication.bookId onPage:currentPage];
    if(pageData != nil)
    {
        CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)pageData);	
        CGDataProviderRetain(dataProvider);
        CGPDFDocumentRef document = CGPDFDocumentCreateWithProvider(dataProvider);
        CGPDFPageRef pageRef = CGPDFDocumentGetPage(document, 1); // get the single page
        
        if (pageRef != nil && ctx != nil) 
        {
            [(NSObject *)pageRef retain];
            CGContextSaveGState(ctx);

            // PDF might be transparent, assume white paper
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
            CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh); 
            CGContextSetRenderingIntent(ctx, kCGRenderingIntentDefault);            
            CGContextDrawPDFPage(ctx, pageRef);
            
            NSArray *selections = [self selectionsForPage: pageRef];
            if (self.searchTerm)
            {
                CGContextSetFillColorWithColor(ctx, [[UIColor yellowColor] CGColor]);
                CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
                for (Selection *s in selections)
                {
                    CGContextSaveGState(ctx);
                    CGContextConcatCTM(ctx, s.transform);
                    CGContextFillRect(ctx, s.frame);
                    CGContextRestoreGState(ctx);
                }
            }
            [selections release];
            
            CGContextEndPage(ctx);
            
            // CGContextRestoreGState(ctx);
            // CGContextRelease(ctx);
            // CGPDFPageRelease(pageRef);
            [(NSObject *)pageRef release];

            CGContextRestoreGState(ctx);
        }
        
        CGPDFDocumentRelease(document);
        CGDataProviderRelease(dataProvider);
        // CGPDFPageRelease(pageRef);
    }
    [pageData release];
    [p release];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches
              withEvent:event];
}

- (void) clear
{
    // [imageView setImage: nil];
}

- (void) dealloc
{
    // [imageView setImage: nil];
    // [player release];
    [super dealloc];
}
@end
