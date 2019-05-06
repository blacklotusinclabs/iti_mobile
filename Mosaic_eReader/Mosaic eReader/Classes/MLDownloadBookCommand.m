//
//  MLDownloadBookCommand.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/29/10.
//  Copyright 2010 . All rights reserved.
//

#import "MLDownloadBookCommand.h"
#import "IPAddress.h"

@implementation MLDownloadBookCommand

@synthesize bookId;

- (NSURL *) url
{
	return [NSURL URLWithString: 
            [NSString stringWithFormat: 
             @"http://%@/Book.asmx/DownloadBook",[self baseURL]]];       
}

- (NSString *) asXML
{
	NSString *format = @"userId=%@&bookId=%@&macAddress=%@&sessionId=%@";
	NSString *macAddress = [NSString stringWithFormat: @"%s",hw_addrs[1]]; // to be filled later...
	
	return [NSString stringWithFormat: format, 
            session.userId, bookId, 
            macAddress,session.sessionId];
}

@end
