//
//  MLDownloadResponse.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/26/10.
//  Copyright 2010 . All rights reserved.
//

#import "MLDownloadResponse.h"
#import "MLDownloadResult.h"

@implementation MLDownloadResponse

@synthesize errors;

- (id) init
{
	if((self = [super init]) != nil)
	{
		dict = [[NSMutableDictionary alloc] init];
		results = [[NSMutableArray alloc] init];
		errors = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[dict release];
	[results release];
	[errors release];
	[super dealloc];
}

- (void) addDownloadResult: (id)obj
{
	MLDownloadResult *result = (MLDownloadResult *)obj;
	[results addObject: result];
}

- (void) addError: (id)error
{
	[errors addObject: error];
}

- (id) resultForKey: (id)key
{
	if([[dict allKeys] count] == 0)
	{
		[self buildDictionary];
	}
	return [dict objectForKey: key];
}

- (BOOL) isEmpty
{
	return ([[dict allKeys] count] == 0);
}

- (void) buildDictionary
{
	for (MLDownloadResult *obj in results) {
		NSString *key = obj.bookId;
		if(key != nil)
		{
			[dict setObject: obj
					 forKey: key];
		}
	}
}

@end
