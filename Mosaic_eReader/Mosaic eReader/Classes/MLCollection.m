//
//  MLCollection.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/21/10.
//  Copyright 2010 . All rights reserved.
//

#import "MLCollection.h"


@implementation MLCollection

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if((self = [super init]) != nil)
	{
		array = [[aDecoder decodeObjectForKey: @"Array"] retain];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject: array forKey: @"Array"];
}

- (id) init
{
	if((self = [super init]) != nil)
	{
		array = [[NSMutableArray alloc] initWithCapacity: 10];
	}
	return self;
}

- (id) initWithArray: (NSMutableArray *)anArray
{
	if((self = [super init]) != nil)
	{
		array = [anArray retain];
	}
	return self;
}

- (void) dealloc
{
	[array release];
	[super dealloc];
}

- (void) addObject: (id)obj
{
	[array addObject: obj];
}

- (id) objectAtIndex:(NSUInteger)index
{
	return [array objectAtIndex: index];
}

- (NSUInteger) count
{
	return [array count];
}

- (NSMutableArray *) array
{
	return array;
}

- (void) buildDictionary
{
	// do nothing...
}

@end
