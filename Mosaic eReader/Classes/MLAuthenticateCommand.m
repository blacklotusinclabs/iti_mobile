//
//  MLAuthenticateCommand.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/6/10.
//  Copyright 2010 . All rights reserved.
//

#import "MLAuthenticateCommand.h"
#import "MLAuthenticateResult.h"
#import "NSString+SHA1.h"
#import "IPAddress.h"

@implementation MLAuthenticateCommand

@synthesize username;
@dynamic password;
@synthesize passwordHash;

- (void) setPassword:(NSString *)pw
{
	passwordHash = 	[pw stringByHashingStringWithSHA1];
}	

- (NSURL *) url
{
	return [NSURL URLWithString: 
            [NSString stringWithFormat: @"http://%@/Security.asmx/Authenticate",[self baseURL]]];
}

- (NSString *) asXML
{
    NSString *macAddress = [NSString stringWithFormat: @"%s",hw_addrs[1]];
	NSString *format = @"userName=%@&passwordHash=%@&macAddress=%@";
	NSString *escapedUsername = [username stringByReplacingOccurrencesOfString: @"+" withString: @"%2B"];
        
	return [NSString stringWithFormat: format, escapedUsername,passwordHash, macAddress];
}

#ifdef TEST
- (id) testResponse
{
	MLAuthenticateResult *response = [[MLAuthenticateResult alloc] init];
	response.userId =  @"29"; // "gomand@mosaicprint.com";
	response.userName = @"gomand";
	response.firstName = @"Greg";
	response.lastName = @"Omand";
	response.isAuthenticated = @"true";
	return (id)response;
}
#endif

/*
- (id) execute
{
	return [self testResponse];
}
*/
@end
