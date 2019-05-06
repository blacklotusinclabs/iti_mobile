//
//  MLCollection.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/21/10.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MLCollection : NSObject <NSCoding>
{
	NSMutableArray *array;
}

- (void) addObject: (id)obj;
- (id) objectAtIndex:(NSUInteger)index;
- (NSUInteger) count;
- (NSMutableArray *) array;
- (void) buildDictionary;
- (id) initWithArray: (NSMutableArray *)an_array;

@end
