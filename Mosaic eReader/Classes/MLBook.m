//
//  MKBook.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/21/10.
//  Copyright 2010 . All rights reserved.
//

#import "MLBook.h"
#import "MLCategories.h"
#import "MLCategory.h"
#import "MLDataStore.h"

@implementation MLBook

@synthesize bookId;
@synthesize drmId;
@synthesize version;
@dynamic title;
@synthesize summary;
@synthesize thumbnailUrl;
@synthesize bookUrl;
@synthesize bookData;
@synthesize categories;
@synthesize numPages;
@synthesize numParts;
@synthesize type;

- (void) dealloc
{
    [bookId release];
    [drmId release];
    [version release];
    [title release];
    [summary release];
    [thumbnailUrl release];
    [categories release];
    [pagesPerPart release];
    [type release];
    [super dealloc];
}

- (id) init
{
    if((self = [super init]) != nil)
    {
        pagesPerPart = [[NSMutableDictionary alloc] init];
        type = @"PDF"; // default value...
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if((self = [super init]) != nil)
	{
		bookId = [[aDecoder decodeObjectForKey: @"bookId"] retain];
		drmId = [[aDecoder decodeObjectForKey: @"drmId"] retain];
		version = [[aDecoder decodeObjectForKey: @"version"] retain];
		title = [[aDecoder decodeObjectForKey: @"title"] retain];
		summary = [[aDecoder decodeObjectForKey: @"summary"] retain];
		thumbnailUrl = [[aDecoder decodeObjectForKey: @"thumbnailUrl"] retain];
		bookData = [[aDecoder decodeObjectForKey: @"bookData"] retain];
        numPages = [aDecoder decodeIntForKey: @"numPages"];
        numParts = [aDecoder decodeIntForKey: @"numParts"];
        type = [[aDecoder decodeObjectForKey: @"type"] retain];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject: bookId forKey: @"bookId"];
	[aCoder encodeObject: drmId forKey: @"drmId"];
	[aCoder encodeObject: version forKey: @"version"];
	[aCoder encodeObject: title forKey: @"title"];
	[aCoder encodeObject: summary forKey: @"summary"];
	[aCoder encodeObject: thumbnailUrl forKey: @"thumbnailUrl"];
	[aCoder encodeObject: bookData forKey: @"bookData"];
    [aCoder encodeInt: numPages forKey: @"numPages"];
    [aCoder encodeInt: numParts forKey: @"numParts"];
    [aCoder encodeObject: type forKey: @"type"];
}

- (void) setTitle: (NSString *)t
{
	if(title != nil)
	{
		t = [title stringByAppendingString: t];
		title = [t retain];
	}
	else
	{
		title = [t retain];
	}
}

- (NSString *)title
{
	return title;
}

- (BOOL) isEqual:(id)object
{
	MLBook *otherbook = (MLBook *)object;
	return ([bookId isEqual: otherbook.bookId]);
}

- (NSString *) description
{
	return [NSString stringWithFormat: 
			@"<MLBook:%d bookid:%@, drmId:%@, version:%@ title:%@ summary:%@ thumbnailUrl:%@>",self,
			self.bookId,
			self.drmId,
			self.version,
			self.title,
			self.summary,
			self.thumbnailUrl];
}

- (BOOL) isAvailable
{
    NSArray *array = [categories array];
    for(MLCategory *category in array)
    {
        NSString *catId = category.categoryId;
        if([catId isEqualToString: @"0"])
        {
            return NO;
        }
    }
    return YES;
}

- (void) setPages: (NSUInteger)pages
          forPart: (NSUInteger)part
{
    MLDataStore *dataStorage = [MLDataStore sharedInstance];
    [dataStorage  setPages: pages
                   forPart: part
                    ofBook: bookId];
}

- (NSUInteger) partForPage: (NSUInteger)page
{
    NSUInteger result = -1;
    NSUInteger totalPages = 0;
    for(NSUInteger index = 0; index < numParts; index++)
    {
        totalPages += [self pagesForPart: index];
        if(totalPages >= page)
        {
            result = index;
            break;
        }
    }
    return result;
}

- (NSUInteger) pagesForPart: (NSUInteger)part
{
    MLDataStore *dataStorage = [MLDataStore sharedInstance];
    return [dataStorage pagesForPart: part ofBook: bookId];
}

- (NSUInteger) partPageNumber: (NSUInteger)page
{
    NSUInteger result = -1;
    NSUInteger totalPages = 0;
    for(NSUInteger index = 0; index < numParts; index++)
    {
        NSUInteger pagesForPart = [self pagesForPart: index];
        totalPages += pagesForPart;
        if(totalPages >= page)
        {
            totalPages -= pagesForPart;
            result = page - totalPages;
            break;
        }
    }
    return result;    
}
@end
