//
//  MLArrayOfBook.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/14/10.
//  Copyright 2010 . All rights reserved.
//

#import "MLArrayOfBook.h"

@implementation MLArrayOfBook

- (id) init
{
	if((self = [super init]) != nil)
	{
		dict = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc
{
	//[dict release];
	[super dealloc];
}

- (void) addBook: (id)obj
{
	[self addObject: obj];
}

- (id) bookForKey: (id)key
{
	if([[dict allKeys] count] == 0)
	{
		[self buildDictionary];
	}
	
	return [dict objectForKey: key];
}

- (void) buildDictionary
{
	for (MLBook *obj in array) 
	{
		NSString *key = obj.bookId;
		[dict setObject: obj
				 forKey: key];
	}
}

@end
