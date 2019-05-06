//
//  SearchCriteria.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchCriteria.h"
#import "MLBook.h"

@implementation SearchCriteria

@synthesize book;
@synthesize terms;


- (id) initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super init]) != nil)
    {
        self.book = [aDecoder decodeObjectForKey: @"book"];
        self.terms = [aDecoder decodeObjectForKey: @"terms"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject: book forKey: @"book"];
    [aCoder encodeObject: terms forKey: @"terms"];
}

@end
