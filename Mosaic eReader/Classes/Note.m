//
//  Note.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Note.h"
#import <time.h>

@implementation Note

@synthesize content;
@synthesize book;
@synthesize page;
@synthesize identifier;

- (id) init
{
    if((self = [super init]) != nil)
    {
        identifier = time(NULL);
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super init]) != nil)
    {
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.book = [aDecoder decodeObjectForKey:@"book"];
        self.page = [aDecoder decodeIntForKey:@"page"];
        identifier = [aDecoder decodeIntForKey: @"identifier"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:content
                  forKey:@"content"];
    [aCoder encodeObject:book
                  forKey:@"book"];
    [aCoder encodeInt:page
               forKey:@"page"];
    [aCoder encodeInt:identifier
               forKey: @"identifier"];
}

/*
- (BOOL) isEqual:(id)object
{    
    if(self == object)
        return YES;
    if(identifier == [object identifier])
        return YES;
    
    return ([content isEqualToString:[object content]] && 
            (page == [object page]));
}
 */
@end
