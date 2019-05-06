//
//  PDFView.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 11/3/10.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PublicationViewController, AVAudioPlayer, MLDataStore, MLBook;

@interface PDFView : UIView {
    MLBook *book;
	NSUInteger currentPage;
	UISwipeGestureRecognizer *forwardRecognizer;
	UISwipeGestureRecognizer *backwardRecognizer;
	UITapGestureRecognizer *tapRecognizer;
	NSUInteger numPages;
	PublicationViewController *pubController;
    MLDataStore *dataStore;
    NSString *searchTerm;
}

// @property (nonatomic,assign) CGPDFDocumentRef document;
@property (nonatomic,assign) PublicationViewController *pubController;
@property (nonatomic,assign) NSUInteger numPages;
@property (nonatomic,assign) MLBook *book;
@property (nonatomic,assign) NSString *searchTerm;

- (void) goToPage: (NSUInteger)pageNum;
- (void) clear;

@end
