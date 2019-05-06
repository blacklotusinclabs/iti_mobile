//
//  SearchResult.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchResult.h"


@implementation SearchResult

@synthesize book;
@synthesize page;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super init]) != nil)
    {
        self.book = [aDecoder decodeObjectForKey: @"book"];
        self.page = [aDecoder decodeIntForKey: @"page"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject: book forKey: @"book"];
    [aCoder encodeInt: page forKey: @"page"];
}

@end
