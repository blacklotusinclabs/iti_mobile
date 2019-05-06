//
//  Note.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLBook.h"

@interface Note : NSObject <NSCoding>
{
    NSString *content;
    MLBook *book;
    NSUInteger page;
    NSUInteger identifier;
}

@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) MLBook *book;
@property (nonatomic, assign) NSUInteger page;
@property (nonatomic, readonly) NSUInteger identifier;

@end
