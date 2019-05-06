//
//  MLCommand.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/5/10.
//  Copyright 2010 . All rights reserved.
//

// #define TEST 1

#import <Foundation/Foundation.h>
#import "MLAuthenticateResult.h"

@interface MLCommand : NSObject 
{
	MLAuthenticateResult *session;
}

@property (nonatomic,retain) MLAuthenticateResult *session;

+ (id) resultWithXML: (NSData *)xml;

- (NSString *) baseURL;

- (NSURL *) url;

- (id)execute;

- (NSString *)asXML;

- (NSData *) dataForRequest: (NSString *) post
					withURL: (NSURL *)url;

#ifdef TEST
- (id) testResponse;
#endif
@end
