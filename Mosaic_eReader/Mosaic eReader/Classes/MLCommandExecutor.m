//
//  MLCommandExecutor.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/5/10.
//  Copyright 2010 . All rights reserved.
//

#import "MLCommandExecutor.h"

static id _sharedCommandExecutor = nil;

@implementation MLCommandExecutor

+ (id) sharedCommandExecutor
{
	if(_sharedCommandExecutor == nil)
	{
		_sharedCommandExecutor = [[MLCommandExecutor alloc] init];
	}
	return _sharedCommandExecutor;
}

- (id) executeCommand: (MLCommand *)command
{
	return [command execute];
}

@end
