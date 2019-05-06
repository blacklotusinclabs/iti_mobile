//
//  Stack.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/13/10.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Stack : NSObject {
	NSMutableArray *array;
}

- (void) push: (id)object;
- (id) pop;
- (id) lastObject;
- (BOOL) isEmpty;

@end
