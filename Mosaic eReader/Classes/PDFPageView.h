//
//  PDFPageView.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 2/3/11.
//  Copyright 2011 . All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PDFPageView : UIView {
	CGPDFPageRef myPageRef;
	CGPDFDocumentRef document;
}

- (void) setDocumentRef: (CGPDFDocumentRef)doc
			 pageNumber: (NSUInteger)page;

@end
