//
//  MLError.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/26/10.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MLError : NSObject {
	NSString *message;
}

@property (nonatomic,retain) NSString *message;

@end
