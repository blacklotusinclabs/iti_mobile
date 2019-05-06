//
//  MLAuthenticateResult.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/6/10.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MLUserGroups.h"
#import "MLUserGroup.h"

@interface MLAuthenticateResult : NSObject <NSCoding>
{
	NSString *userId;
	NSString *userName;
	NSString *firstName;
	NSString *lastName;
	MLUserGroups *userGroups;
	NSString *isAuthenticated;
	NSString *isBookAdmin;
    NSString *sessionId;
	NSDate *accessDate;
	BOOL guestUser;
}

@property (nonatomic,retain) NSString *userId;
@property (nonatomic,retain) NSString *userName;
@property (nonatomic,retain) NSString *firstName;
@property (nonatomic,retain) NSString *lastName;
@property (nonatomic,retain) NSString *sessionId;
@property (nonatomic,retain) NSDate *accessDate;
@property (nonatomic,assign) BOOL guestUser;

- (void) addUserGroups: (MLUserGroup *)group;

- (NSString *) isAuthenticated;

- (void) setIsAuthenticated: (NSString *)value;

- (BOOL) isAuthenticatedAsBool;

- (void) setIsBookAdmin: (NSString *)value;

- (NSString *) isBookAdmin;

- (BOOL) isAuthenticatedAsBool;

@end
