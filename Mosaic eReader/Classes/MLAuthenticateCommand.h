//
//  MLAuthenticateCommand.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/6/10.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLCommand.h"

@interface MLAuthenticateCommand : MLCommand 
{
	NSString *username;
	NSString *password;
	NSString *passwordHash;
}

@property (nonatomic,retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (readonly) NSString *passwordHash;

@end
