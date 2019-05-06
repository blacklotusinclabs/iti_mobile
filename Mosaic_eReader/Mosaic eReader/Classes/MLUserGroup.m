//
//  MLUserGroup.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/7/10.
//  Copyright 2010 . All rights reserved.
//

#import "MLUserGroup.h"


@implementation MLUserGroup

@synthesize groupId;
@synthesize name;

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if((self = [super init]) != nil)
	{
		groupId = [[aDecoder decodeObjectForKey:@"GroupID"] retain];
		name = [[aDecoder decodeObjectForKey:@"Name"] retain];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:groupId forKey:@"GroupID"];
	[aCoder encodeObject:name forKey:@"Name"];
}

@end
