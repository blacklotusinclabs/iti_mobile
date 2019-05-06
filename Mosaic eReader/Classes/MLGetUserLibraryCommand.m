//
//  MLGetUserLibraryCommand.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/15/10.
//  Copyright 2010 . All rights reserved.
//

#import "MLGetUserLibraryCommand.h"
#import "MLAPICommunicator.h"
#import "MLArrayOfBook.h"
#import "IPAddress.h"
#import "MLError.h"

@implementation MLGetUserLibraryCommand

- (NSURL *) url
{
	return [NSURL URLWithString: 
            [NSString stringWithFormat: 
             @"http://%@/Book.asmx/GetUserLibrary",[self baseURL]]];    
}

- (NSString *) asXML
{
	NSString *format = @"userId=%@&macAddress=%@&sessionId=%@";
	NSString *macAddress = [NSString stringWithFormat: @"%s",hw_addrs[1]];
	
	return [NSString stringWithFormat: format, session.userId, macAddress,session.sessionId];
}

- (id) execute
{
	NSArray *downloadedBooks = [[MLAPICommunicator sharedCommunicator] retrieveDownloadedBooks];
	id result = [super execute];
    if([result isKindOfClass:[MLError class]] == NO)
    {
        NSMutableArray *userLibrary = [result array];
        [userLibrary removeObjectsInArray:downloadedBooks];
        return [[[MLArrayOfBook alloc] initWithArray: userLibrary] autorelease];
    }
    else 
    {
        [NSException raise:NSInternalInconsistencyException
                    format:[result message]];
    }
    return nil;
}
@end
