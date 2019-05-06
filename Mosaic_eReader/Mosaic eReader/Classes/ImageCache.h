//
//  ImageCache.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject
{
    NSMutableDictionary *imageCache;
}

+ (ImageCache *) sharedCache;
- (void) addImage: (UIImage *)image 
         withName: (NSString *)name;
- (UIImage *) imageForName: (NSString *)name;
- (void) emptyCache;
@end
