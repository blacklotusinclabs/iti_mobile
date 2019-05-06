//
//  MLDownloadResult.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/26/10.
//  Copyright 2010 . All rights reserved.
//

#import "MLDownloadResult.h"


@implementation MLDownloadResult

@synthesize bookId;
@synthesize drmId;
@synthesize key;
@synthesize bookUrl;
@synthesize bookBytes;
@synthesize thumbnailUrl;
@synthesize isSplit;
@synthesize bookFiles;
@synthesize pageCount;
@synthesize bookFormat;
@synthesize version;

- (void) dealloc
{
	[bookId release];
	[drmId release];
	[key release];
	[bookUrl release];
	[bookBytes release];
	[thumbnailUrl release];
    [bookFormat release];
    [version release];

	[super dealloc];
}

- (NSString *) description
{
	return [NSString stringWithFormat: 
			@"<MLDownloadResult:%@\n bookid:%@\n drmId:%@\n key:%@\n bookUrl:%@\n bookBytes:%@\n thumbnailUrl:%@\n bookFormat: %@>",self,
			self.bookId,
			self.drmId,
			self.key,
			self.bookUrl,
			self.bookBytes,
			self.thumbnailUrl,
            self.bookFormat,
            self.version];
}

- (BOOL) isSplitBool
{
    return [isSplit isEqualToString: @"true"];
}

@end
