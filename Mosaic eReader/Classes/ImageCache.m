//
//  ImageCache.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageCache.h"

static ImageCache *_shared_cache = nil;

@implementation ImageCache


+ (ImageCache *) sharedCache
{
    if(_shared_cache == nil)
    {
        _shared_cache = [[self alloc] init];
    }
    return _shared_cache;
}

- (id)init
{
    self = [super init];
    if (self) {
        imageCache = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    return self;
}

- (void) addImage: (UIImage *)image 
         withName: (NSString *)name
{
    [imageCache setObject: image
                   forKey: name];
    // [image release];
}

- (UIImage *) imageForName: (NSString *)name
{
    return [imageCache objectForKey: name];
}

- (void) emptyCache
{
    [imageCache removeAllObjects];
}

- (void) dealloc
{
    [imageCache release];
    [super dealloc];
}

@end
