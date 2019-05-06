//
//  MLCommand.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/5/10.
//  Copyright 2010 . All rights reserved.
//

#import "MLCommand.h"
#import "XMLObjectParser.h"

@implementation MLCommand

@synthesize session;

+ (id) resultWithXML: (NSData *)xml
{
	XMLObjectParser *parser = [[XMLObjectParser alloc] initWithData: xml andNameSpace: @"ML"];
    [parser autorelease];
	return [parser parse];
}

- (NSData *) dataForRequest: (NSString *) post
					withURL: (NSURL *)url
{
	NSData *postData = [post dataUsingEncoding: NSUTF8StringEncoding 
						  allowLossyConversion: YES];		
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	
	[request setURL: url];
	[request setHTTPMethod:@"POST"];
	[request addValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	NSError *error = nil;
	NSURLResponse *response = nil;
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if(error != nil)
	{
		return nil;
	}
	
	NSLog(@"Response is: %s",[urlData bytes]);
	
	return urlData;	
}

- (NSString *)baseURL
{
    return @"dev.library.mosaiclearning.com";
    // return @"library.codexmobile.com";
}


- (NSURL *) url
{
	return nil;
}

#ifdef TEST
- (id) testResponse
{
	return nil;
}
#endif

- (id) execute
{
#ifndef TEST
	NSData *result = [self dataForRequest: [self asXML] withURL: [self url]];
	return [MLCommand resultWithXML: result];
#else
	return [self testResponse];
#endif
}

- (NSString *) asXML
{
	return nil;
}

@end
