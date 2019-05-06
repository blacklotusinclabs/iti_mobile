//
//  MLArrayOfBook.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/14/10.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLBook.h"
#import "MLCollection.h"

@interface MLArrayOfBook : MLCollection
{
	NSMutableDictionary *dict;
}

- (void) addBook: (id)obj;
- (id) bookForKey: (id)key;

@end
