//
//  Stack.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/13/10.
//  Copyright 2010 . All rights reserved.
//

#import "Stack.h"


@implementation Stack

- (id) init
{
	if((self = [super init]) != nil)
	{
		array = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[array release];
	[super dealloc];
}

- (void) push: (id)object;
{
	[array addObject: object];
}

- (id) pop
{
	id obj = [array lastObject];
	if(obj != nil)
	{
		[array removeLastObject];
	}
	return obj;
}

- (id) lastObject
{
	return [array lastObject];
}

- (BOOL) isEmpty
{
	return ([array count] == 0);
}

@end
