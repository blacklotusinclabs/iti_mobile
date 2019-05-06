//
//  MKBook.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/21/10.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLCategories.h"

@interface MLBook : NSObject <NSCoding> {
	NSString *bookId;
	NSString *drmId;
	NSString *version;
	NSString *title;
	NSString *summary;
	NSString *thumbnailUrl;
    NSString *bookUrl;    
	MLCategories *categories;
	NSData *bookData;
    NSUInteger numPages;
    NSUInteger numParts;
    NSMutableDictionary *pagesPerPart;
    NSString *type;
}

@property (nonatomic,retain) NSString *bookId;
@property (nonatomic,retain) NSString *drmId;
@property (nonatomic,retain) NSString *version;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *summary;
@property (nonatomic,retain) NSString *thumbnailUrl;
@property (nonatomic,retain) NSString *bookUrl;
@property (nonatomic,retain) NSData *bookData;
@property (nonatomic,retain) MLCategories *categories;
@property (nonatomic,assign) NSUInteger numPages;
@property (nonatomic,assign) NSUInteger numParts;
@property (nonatomic,assign) NSString *type;

- (BOOL) isAvailable;
- (void) setPages: (NSUInteger)pages
          forPart: (NSUInteger)part;
- (NSUInteger) partForPage: (NSUInteger)page;
- (NSUInteger) pagesForPart: (NSUInteger)part;
- (NSUInteger) partPageNumber: (NSUInteger)page;

@end
