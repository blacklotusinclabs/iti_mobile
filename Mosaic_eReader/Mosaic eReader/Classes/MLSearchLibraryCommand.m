//
//  MLSearchLibraryCommand.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MLSearchLibraryCommand.h"
#import "MLAPICommunicator.h"
#import "MLArrayOfBook.h"
#import "IPAddress.h"

@implementation MLSearchLibraryCommand

@synthesize searchTerm;

- (NSURL *) url
{
    return [NSURL URLWithString: 
            [NSString stringWithFormat: 
             @"http://%@/Book.asmx/SearchLibrary",[self baseURL]]];    
}

- (NSString *) asXML
{
	NSString *format = @"userId=%@&macAddress=%@&searchTerm=%@&sessionId=%@";
	NSString *macAddress = [NSString stringWithFormat: @"%s",hw_addrs[1]]; // to be filled later...
	
	return [NSString stringWithFormat: format, session.userId, macAddress, searchTerm,session.sessionId];
}
@end
