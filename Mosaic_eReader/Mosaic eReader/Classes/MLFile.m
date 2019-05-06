//
//  MLFile.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MLFile.h"

@implementation MLFile

@synthesize fileUrl;
@synthesize fileBytes;
@synthesize orderBy;
@synthesize pageCount;

- (void) dealloc
{
    [fileUrl release];
    [fileBytes release];
    [orderBy release];
    [pageCount release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end
