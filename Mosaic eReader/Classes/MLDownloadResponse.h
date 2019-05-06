//
//  MLDownloadResponse.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/26/10.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MLDownloadResponse : NSObject {	
	NSMutableArray *results;
	NSMutableArray *errors;	
	NSMutableDictionary *dict;
}

@property (nonatomic,retain) NSMutableArray *errors;

- (void) addDownloadResult: (id)result;
- (void) addError: (id)error;
- (id) resultForKey: (id)key;
- (void) buildDictionary;
- (BOOL) isEmpty;
@end
