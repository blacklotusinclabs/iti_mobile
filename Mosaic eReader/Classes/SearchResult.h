//
//  SearchResult.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLBook.h"

@interface SearchResult : NSObject <NSCoding> {
    MLBook *book;
    NSUInteger page;
}

@property (nonatomic,retain) MLBook *book;
@property (nonatomic,assign) NSUInteger page;

@end
